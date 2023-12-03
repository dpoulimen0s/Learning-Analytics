####################
#Data Preprocessing#
####################

# Enrollments data files manipulation
####################################
# Initialize a list to store cleaned files
cleaned_files <- list()

# Process all seven files
for (run_number in 1:7) {
  filename <- sprintf("data/cyber-security-%d_enrolments.csv", run_number)
  df <- read.csv(filename, header = TRUE)
  df <- df[rowSums(df == "Unknown", na.rm = TRUE) == 0, ]
  df$Run <- sprintf("Run_%d", run_number)  # Create the 'Run' column
  cleaned_files[[run_number]] <- df
}

# Combine all the cleaned files into one data frame
combined_enrolments_data <- bind_rows(cleaned_files)

combined_enrolments_data <- combined_enrolments_data %>%
  select(
    -unenrolled_at,
    -role,
    -fully_participated_at,
    -purchased_statement_at,
    -employment_status,
    -employment_area,
    -detected_country
  )

# Step Activity data files manipulation
#######################################
# Initialize a list to store cleaned files
cleaned_files_step <- list()

# Process all seven files
for (run_number in 1:7) {
  filename <- sprintf("data/cyber-security-%d_step-activity.csv", run_number)
  df <- read.csv(filename, header = TRUE)
  df <- df[rowSums(df == "Unknown", na.rm = TRUE) == 0, ]
  # Create the 'Run' column
  df$Run <- sprintf("Run_%d", run_number)  
  
  # Create the 'Completed' column based on 'last_completed_at'
  df <- df %>%
    mutate(Completed = ifelse(is.na(last_completed_at) | last_completed_at == "", "Not Completed", "Completed"))
  
  cleaned_files_step[[run_number]] <- df
}

# Combine all the cleaned files into one data frame
combined_step_activity_data <- bind_rows(cleaned_files_step)

# Join the 2 data frames
# Determine the shared columns for the join
join_columns <- c("learner_id")

# Inner join based on 'learner_id'
result <- inner_join(combined_step_activity_data, combined_enrolments_data, by = join_columns, relationship = "many-to-many") %>%
  select(-Run.y) %>%
  rename(Run = Run.x)%>%
  select(-Run, everything(), Run)

# Remove duplicates based on 'learner_id' and 'step'
Final_dataframe <- distinct(result, learner_id, step, .keep_all = TRUE)

# Create a new column for "Course_Status" based on Completed column
Final_dataframe <- Final_dataframe %>%
  mutate(Course_Status = ifelse(Completed == "Not Completed", "Fail", "Pass"))


################
# Visualisation#
################

# 1.5.1.1
# Count the number of distinct learner_id per Run 
distinct_learner_count <- Final_dataframe %>%
  group_by(Run) %>%
  summarise(DistinctLearners = n_distinct(learner_id))

# 1.5.1.2
# Calculate the count of distinct "highest_education_level" values per Run 
distinct_education_counts <- Final_dataframe %>%
  group_by(Run, highest_education_level) %>%
  summarise(DistinctCount = n_distinct(learner_id))

# 1.5.1.3
# Group by "Run," "highest_education_level," and "Completion_Status" 
grouped_data <- Final_dataframe %>%
  group_by(Run, highest_education_level, Course_Status) %>%
  summarise(Count = n_distinct(learner_id))

# Reorder the levels of the Course_Status variable
grouped_data$Course_Status <- factor(grouped_data$Course_Status, levels = c("Pass", "Fail"))

# 1.5.1.4
# Filter for the first 4 education levels
data_first_four <- Final_dataframe %>%
  filter(highest_education_level %in% c("apprenticeship", "less_than_secondary", "professional", "secondary"))

# Group by "Run," "highest_education_level," and "Course_Status" and calculate distinct learner IDs
grouped_data_first_four <- data_first_four %>%
  group_by(Run, highest_education_level, Course_Status) %>%
  summarise(Count = n_distinct(learner_id))

# Reorder the levels of the Course_Status variable
grouped_data_first_four$Course_Status <- factor(grouped_data_first_four$Course_Status, levels = c("Pass", "Fail"))

# Filter for the last 4 education levels
data_last_four <- Final_dataframe %>%
  filter(highest_education_level %in% c("tertiary", "university_degree", "university_doctorate", "university_masters"))

# Group by "Run," "highest_education_level," and "Course_Status" and calculate distinct learner IDs
grouped_data_last_four <- data_last_four %>%
  group_by(Run, highest_education_level, Course_Status) %>%
  summarise(Count = n_distinct(learner_id))

# Reorder the levels of the Course_Status variable
grouped_data_last_four$Course_Status <- factor(grouped_data_last_four$Course_Status, levels = c("Pass", "Fail"))

# 2.3.1.1
# Filter the data for the last 2 runs
data_last_two_runs <- Final_dataframe %>%
  filter(Run %in% c("Run_6", "Run_7"))

# Group by "Run" and "gender" and calculate the count of distinct learner IDs
grouped_data_gender <- data_last_two_runs %>%
  group_by(Run, gender) %>%
  summarise(Count = n_distinct(learner_id))

# 2.3.1.2
# Create a new column "Overall_Status" based on whether there's at least one "Fail" for each learner_id
data_last_two_runs <- data_last_two_runs %>%
  group_by(learner_id) %>%
  mutate(Overall_Status = ifelse("Fail" %in% Course_Status, "Fail", "Pass"))

# Calculate the count of distinct learner_id and Overall_Status
distinct_count_course_status <- data_last_two_runs %>%
  group_by(Run, Overall_Status) %>%
  summarise(Count = n_distinct(learner_id))

# 2.3.1.3
# Filter for those who have Passed
data_passed <- data_last_two_runs %>%
  filter(Overall_Status == "Pass")

# Calculate the count of distinct learner_id, gender, and Overall_Status
distinct_count_gender_passed <- data_passed %>%
  group_by(Run, gender) %>%
  summarise(Count = n_distinct(learner_id))
