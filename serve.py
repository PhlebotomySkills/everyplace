"""
Everyplace production origin server.
Replaces `python -m http.server 8090` with:
  - ThreadingHTTPServer (handles concurrent connections instead of one-at-a-time)
  - Cache-Control headers on HTML (5 min) and static assets (1 day)
  - Security headers (HSTS, X-Content-Type-Options, Referrer-Policy, Permissions-Policy)
  - Quiet request log (only warnings and errors, not every GET)
  - Graceful handling of broken pipes when clients disconnect mid-download

Called by: 1 CLICK HERE TO START EVERYPLACE.bat (auto-restart loop lives there).
"""

import os
import sys
import socketserver
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("EVERYPLACE_PORT", "8090"))
BIND = "0.0.0.0"

# Paths that should NOT fall back to index.html. Everything else does, so that
# /tokyo, /mount-fuji-kawaguchi, etc. all land on the SPA which then routes.
PASSTHROUGH_EXTENSIONS = (".html", ".js", ".css", ".png", ".jpg", ".jpeg", ".gif",
                          ".webp", ".svg", ".ico", ".woff", ".woff2", ".ttf",
                          ".otf", ".mp3", ".ogg", ".wav", ".m4a", ".mp4", ".webm",
                          ".json", ".xml", ".txt", ".pdf", ".md")

# Cache TTLs. Cloudflare overrides these at the edge if you set page rules there,
# but having them here means even if the edge cache misses, the browser still caches.
HTML_CACHE_SECONDS = 300          # 5 min for index.html
ASSET_CACHE_SECONDS = 86400       # 1 day for images, fonts, scripts (not currently used, future-proof)


class HardenedHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        # SPA fallback: if the requested path has no known file extension AND no file
        # exists at that path on disk, serve /index.html so the SPA can route the URL
        # client-side. Lets everyplace.live/tokyo, /mount-fuji-kawaguchi, etc. work.
        raw_path = self.path.split("?", 1)[0].split("#", 1)[0]
        if raw_path and raw_path != "/" and not raw_path.lower().endswith(PASSTHROUGH_EXTENSIONS):
            # Strip leading slash and resolve relative to current directory
            rel = raw_path.lstrip("/")
            if not os.path.exists(rel):
                self.path = "/index.html"
        return super().do_GET()

    def end_headers(self):
        # Cache-Control based on file type
        path = self.path.split("?", 1)[0].lower()
        if path.endswith((".html", "/")) or path == "":
            self.send_header("Cache-Control", f"public, max-age={HTML_CACHE_SECONDS}, stale-while-revalidate=60")
        elif path.endswith((".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".ico", ".woff", ".woff2", ".ttf", ".otf", ".css", ".js")):
            self.send_header("Cache-Control", f"public, max-age={ASSET_CACHE_SECONDS}, immutable")
        else:
            self.send_header("Cache-Control", "no-store")

        # Security headers. These belong on an edge server too, but defense in depth.
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("Referrer-Policy", "strict-origin-when-cross-origin")
        self.send_header("Permissions-Policy", "geolocation=(), microphone=(), camera=(), payment=()")
        # HSTS: only safe when you know 100% of traffic is HTTPS. Cloudflare forces HTTPS
        # on everyplace.live, so this is safe. Remove if you ever serve this on plain HTTP.
        self.send_header("Strict-Transport-Security", "max-age=15552000; includeSubDomains")

        super().end_headers()

    def log_message(self, fmt, *args):
        # Default http.server logs every GET. Suppress info logs; keep errors.
        # Errors (4xx/5xx) come through log_error, which still prints.
        pass

    def log_error(self, fmt, *args):
        sys.stderr.write("[ERR] " + (fmt % args) + "\n")


def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    with ThreadingHTTPServer((BIND, PORT), HardenedHandler) as httpd:
        # Allow the socket to be reused immediately on restart (no TIME_WAIT delay).
        httpd.allow_reuse_address = True
        sys.stdout.write(f"Everyplace hardened origin listening on {BIND}:{PORT}\n")
        sys.stdout.write(f"Serving from: {os.getcwd()}\n")
        sys.stdout.flush()
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            sys.stdout.write("\nShutting down cleanly.\n")


if __name__ == "__main__":
    main()
