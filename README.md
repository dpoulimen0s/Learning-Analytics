# Project Structure and Execution Guide

## Project Template Overview

This project is organized with the following structure:

- **reports:**
  - `FutureLearn-Analysis-Report.pdf`: Main report file containing the analysis details.
  - `FutureLearn Analysis Report.Rmd`: Rmarkdown version of the analysis report containing all the code to generate the pdf.

- **log:**
  - `Gitlog.txt`: Git log file capturing version control history.

- **munge:**
  - `01-A.R`: R script file which contains the code been used for data manipulation

## Running the Analysis

### 1. Install R and RStudio
   Ensure you have the latest versions of R and RStudio installed on your computer.

### 2. Set Working Directory
   Open RStudio and set the working directory to the main folder of the project (`FutureLearn_Analysis`).

### 3. Open Analysis Report
   - Navigate to the `reports` folder.
   - Open the `FutureLearn-Analysis-Report.Rmd` file.

### 4. Run the Analysis
   - Press the "Knit" button in RStudio to execute the analysis.
   - The analysis report will be generated and displayed in your browser.

### 5. Install LaTeX (if needed)
   If LaTeX is not installed on your system, you may need to install it before knitting the report in order to generate the pdf version of it.

   Use the following R code within RStudio:
   ```R
   install.packages("tinytex")
   tinytex::install_tinytex()
