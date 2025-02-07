import os
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from PIL import Image
from datetime import datetime
from PyPDF2 import PdfMerger
from robot.libraries.BuiltIn import BuiltIn

class Merger():
    @staticmethod
    def create_pdf(screenshot_directory):
        # Retrieve the current test case file name from the BuiltIn library
        test_case_file = BuiltIn().get_variable_value('${SUITE SOURCE}')
        
        # Extract the directory of the test case file
        base_dir = os.path.abspath(os.path.dirname(test_case_file))

        # Search upwards for the 'Reports' directory
        reports_dir = find_reports_directory(base_dir)

        if reports_dir:
            # Generate output PDF path using the test case file name
            pdf_filename = os.path.basename(test_case_file).replace('.robot', '.pdf')
            output_pdf = os.path.join(reports_dir, pdf_filename)

            # Initialize PdfMerger for combining PDFs
            pdf_merger = PdfMerger()

            try:
                # Iterate through image files in the specified directory
                for filename in os.listdir(screenshot_directory):
                    if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
                        image_path = os.path.join(screenshot_directory, filename)

                        # Capture screenshot excluding the taskbar
                        screenshot = Image.open(image_path)
                        screen_width, screen_height = screenshot.size
                        screenshot = screenshot.crop((0, 0, screen_width, screen_height))

                        # Calculate aspect ratio
                        aspect_ratio = float(screen_width) / float(screen_height)

                        # Adjust width and height to maintain aspect ratio
                        width = A4[0]
                        height = width / aspect_ratio

                        # Calculate the vertical position to align the image at the bottom
                        horizontal_position = (A4[0] - width) / 2
                        vertical_position = (A4[1] - height) / 2

                        # Create a new canvas for each image
                        temp_pdf_path = os.path.join(reports_dir, f"temp_{filename}.pdf")
                        c = canvas.Canvas(temp_pdf_path, pagesize=A4)
                        c.setFont("Helvetica", 11)

                        # Draw image
                        c.drawInlineImage(screenshot, horizontal_position, vertical_position, width=width, height=height)

                        # Generate new filename with current date and old filename
                        file_name, file_extension = os.path.splitext(filename)
                        current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
                        new_filename = f"{current_time}_{file_name}{file_extension}"

                        # Save screenshot to Reports folder with new filename
                        report_path = os.path.join(reports_dir, new_filename)
                        screenshot.save(report_path)

                        # Add text annotation with filename below the image
                        text = f"Filename: {new_filename}, Time: {current_time}"
                        c.drawString(horizontal_position + 10, vertical_position - 15, text)

                        # Save and close the canvas
                        c.showPage()
                        c.save()

                        # Add the saved PDF page to the PdfMerger
                        pdf_merger.append(temp_pdf_path)

                # Save the combined PDF file
                with open(output_pdf, 'wb') as out_pdf:
                    pdf_merger.write(out_pdf)

                print(f"PDF created successfully: {output_pdf}")

            except Exception as e:
                print(f"Error occurred during PDF creation: {e}")

            finally:
                pdf_merger.close()
                # Clean up temporary PDF files
                for filename in os.listdir(reports_dir):
                    if filename.startswith("temp_") and filename.endswith(".pdf"):
                        os.remove(os.path.join(reports_dir, filename))
        else:
            print("Reports directory not found. PDF creation aborted.")

def find_reports_directory(start_dir):
    """
    Recursively search upwards from start_dir for the 'Reports' directory.
    Return the path to 'Reports' directory if found, else return None.
    """
    current_dir = start_dir
    while True:
        reports_dir = os.path.join(current_dir, 'Reports')
        if os.path.exists(reports_dir) and os.path.isdir(reports_dir):
            return reports_dir
        # Move one directory up
        parent_dir = os.path.dirname(current_dir)
        if parent_dir == current_dir:
            break  # Reached root directory
        current_dir = parent_dir
    return None

# Usage example:
if __name__ == "__main__":
    screenshot_directory = r'C:\path\to\screenshot\directory'
    Merger.create_pdf(screenshot_directory)
