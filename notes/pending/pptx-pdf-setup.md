# PPTX & PDF Generation Setup

Additional packages needed in the container for generating PowerPoint presentations and converting them to PDF.

## Runtime Dependencies (not in base image)

### LibreOffice (PPTX to PDF conversion)

```bash
sudo apt-get install -y libreoffice-impress libreoffice-common
```

### Poppler (PDF to image for visual QA)

```bash
sudo apt-get install -y poppler-utils
```

### Node.js packages (slide generation via PptxGenJS)

Install locally per project (global npm install fails due to permissions):

```bash
npm init -y
npm install pptxgenjs react react-dom sharp react-icons
```

### Python package (text extraction from PPTX)

```bash
pip install "markitdown[pptx]" --break-system-packages
```

## Optional: Bake into Dockerfile

To avoid reinstalling each session, add to `Dockerfile`:

```dockerfile
# LibreOffice + Poppler for PPTX/PDF workflows
RUN apt-get update && apt-get install -y --no-install-recommends \
    libreoffice-impress libreoffice-common poppler-utils \
    && rm -rf /var/lib/apt/lists/*
```

## Conversion Commands

```bash
# PPTX -> PDF
python3 ~/.claude/skills/pptx/scripts/office/soffice.py --headless --convert-to pdf output.pptx

# PDF -> slide images (for visual QA)
pdftoppm -jpeg -r 150 output.pdf slide
# produces slide-01.jpg, slide-02.jpg, ...
```
