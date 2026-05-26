#!/usr/bin/env python3
import http.server, urllib.request, urllib.parse, json, ssl, sys, os, glob

USB = os.path.dirname(os.path.abspath(__file__))
matches = glob.glob(os.path.join(USB, 'python-portable', 'lib', 'python3*', 'site-packages'))
if matches:
    sys.path.insert(0, matches[0])

try: import PyPDF2; HAS_PDF = True
except ImportError: HAS_PDF = False
try: import docx; HAS_DOCX = True
except ImportError: HAS_DOCX = False
try: import openpyxl; HAS_XLSX = True
except ImportError: HAS_XLSX = False
try: import pptx; HAS_PPTX = True
except ImportError: HAS_PPTX = False

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *args): pass

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, X-File-Type')
        self.end_headers()

    def send_json(self, code, data):
        body = json.dumps(data, ensure_ascii=False).encode('utf-8')
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Length', len(body))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path.startswith('/search?'):
            self.handle_search()
        else:
            self.send_json(404, {'error': 'Not found'})

    def do_POST(self):
        filetype = self.headers.get('X-File-Type', 'pdf').lower()
        length = int(self.headers.get('Content-Length', 0))
        data = self.rfile.read(length)
        if filetype == 'pdf':
            self.handle_pdf(data)
        elif filetype == 'docx':
            self.handle_docx(data)
        elif filetype == 'xlsx':
            self.handle_xlsx(data)
        elif filetype == 'pptx':
            self.handle_pptx(data)
        else:
            self.send_json(400, {'error': 'Tipo no soportado'})

    def handle_search(self):
        params = urllib.parse.parse_qs(self.path.split('?',1)[1])
        query = params.get('q', [''])[0]
        if not query:
            self.send_json(400, {'error': 'No query'}); return
        try:
            url = 'https://html.duckduckgo.com/html/?q=' + urllib.parse.quote(query)
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            ctx = ssl.create_default_context()
            with urllib.request.urlopen(req, context=ctx, timeout=8) as r:
                html = r.read().decode('utf-8', errors='ignore')
            import re
            snippets = re.findall(r'class="result__snippet"[^>]*>(.*?)</a>', html, re.DOTALL)
            titles = re.findall(r'class="result__title"[^>]*>.*?<a[^>]*>(.*?)</a>', html, re.DOTALL)
            def clean(t): return re.sub(r'<[^>]+>', '', t).strip()
            results = []
            for i in range(min(5, len(snippets))):
                title = clean(titles[i]) if i < len(titles) else ''
                snippet = clean(snippets[i])
                if snippet: results.append({'title': title, 'snippet': snippet})
            self.send_json(200, {'results': results})
        except Exception as e:
            self.send_json(500, {'error': str(e)})

    def handle_pdf(self, data):
        if not HAS_PDF:
            self.send_json(500, {'error': 'PyPDF2 no disponible'}); return
        try:
            import io
            reader = PyPDF2.PdfReader(io.BytesIO(data))
            text = ''.join(page.extract_text() or '' for page in reader.pages)
            self.send_json(200, {'text': text[:8000], 'pages': len(reader.pages), 'type': 'pdf'})
        except Exception as e:
            self.send_json(500, {'error': str(e)})

    def handle_docx(self, data):
        if not HAS_DOCX:
            self.send_json(500, {'error': 'python-docx no disponible'}); return
        try:
            import io
            doc = docx.Document(io.BytesIO(data))
            text = '\n'.join(p.text for p in doc.paragraphs if p.text.strip())
            self.send_json(200, {'text': text[:8000], 'paragraphs': len(doc.paragraphs), 'type': 'docx'})
        except Exception as e:
            self.send_json(500, {'error': str(e)})

    def handle_xlsx(self, data):
        if not HAS_XLSX:
            self.send_json(500, {'error': 'openpyxl no disponible'}); return
        try:
            import io
            wb = openpyxl.load_workbook(io.BytesIO(data), read_only=True, data_only=True)
            text = ''
            for sheet in wb.sheetnames:
                ws = wb[sheet]
                text += f'[Hoja: {sheet}]\n'
                for row in ws.iter_rows(values_only=True):
                    row_text = '\t'.join(str(c) if c is not None else '' for c in row)
                    if row_text.strip():
                        text += row_text + '\n'
            self.send_json(200, {'text': text[:8000], 'sheets': len(wb.sheetnames), 'type': 'xlsx'})
        except Exception as e:
            self.send_json(500, {'error': str(e)})

    def handle_pptx(self, data):
        if not HAS_PPTX:
            self.send_json(500, {'error': 'python-pptx no disponible'}); return
        try:
            import io
            prs = pptx.Presentation(io.BytesIO(data))
            text = ''
            for i, slide in enumerate(prs.slides):
                text += f'[Diapositiva {i+1}]\n'
                for shape in slide.shapes:
                    if hasattr(shape, 'text') and shape.text.strip():
                        text += shape.text + '\n'
            self.send_json(200, {'text': text[:8000], 'slides': len(prs.slides), 'type': 'pptx'})
        except Exception as e:
            self.send_json(500, {'error': str(e)})


if __name__ == '__main__':
    print(f'Proxy en 8081 — PDF:{HAS_PDF} DOCX:{HAS_DOCX} XLSX:{HAS_XLSX} PPTX:{HAS_PPTX}')
    server = http.server.HTTPServer(('127.0.0.1', 8081), Handler)
    server.serve_forever()
