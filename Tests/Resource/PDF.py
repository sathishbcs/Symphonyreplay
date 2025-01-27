import os
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from PIL import Image
from datetime import datetime

class PDF():
    @staticmethod
    def create_pdf(screenshot_directory, output_pdf):
        c = canvas.Canvas(output_pdf, pagesize=A4)

        # Set font for the text
        font_name = "Helvetica"  # Replace with the desired font name
        font_size = 11  # Replace with the desired font size
        c.setFont(font_name, font_size)

        # Iterate through image files in the specified directory
        for filename in os.listdir(screenshot_directory):
            if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
                image_path = os.path.join(screenshot_directory, filename)

                # Capture screenshot excluding the taskbar
                screenshot = Image.open(image_path)
                screen_width, screen_height = screenshot.size
                # taskbar_height = 70  # Adjust the taskbar height based on your setup
                # cropped_height = screen_height - taskbar_height
                screenshot = screenshot.crop((0, 0, screen_width, screen_height))

                # Calculate aspect ratio
                aspect_ratio = float(screen_width) / float(screen_height)

                # Adjust width and height to maintain aspect ratio
                width = A4[0]  # Use the full width of the page
                height = width / aspect_ratio

                # Calculate the vertical position to align the image at the bottom
                horizontal_position = (A4[0] - width) / 2
                vertical_position = (A4[1] - height) / 2

                # Draw image
                c.drawInlineImage(screenshot, horizontal_position, vertical_position, width=width, height=height)

                # Get current time and format it
                current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

                # Add text annotation with filename below the image
                text = """Filename: {}, Time: {}""".format(filename, current_time)
                c.drawString(horizontal_position + 10, vertical_position - 15, text)  # Adjust the position for text

                c.showPage()

        c.save()

# Usage
if __name__ == "__main__":
    pdf_instance = PDF()
    pdf_instance.create_pdf(screenshot_directory, output_pdf)
