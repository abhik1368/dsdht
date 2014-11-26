library(shiny)

shinyUI(pageWithSidebar(
  
  headerPanel("Diabetes Risk Calculator"),
  
  sidebarPanel(
    h3('How Much Should you Weigh For your Age & Height?'),
    p('To determine how much you should weigh
      (your ideal body weight) several factors
      should be considered, including age, 
      muscle-fat ratio, height, sex, smoking ,family history, medications and bone 
      density.'),
    
    h3('Body Mass Index(BMI)'),
    p('Your BMI is your weight in relation to your height.'),
    
    numericInput(
      'weight',
      'Weight in kilogram(kg)',
      0,
      min = NA,
      max = NA,
      step = NA
    ),
    
    numericInput(
      'height',
      'Height in centi-meter(cm)',
      0,
      min = NA,
      max = NA,
      step = NA),
    
    submitButton('Your BMI'),
    
    h3('Diabities Risk Factor (as a percentage)'),
    p('Your Diabities Risk Factor as http://reference.medscape.com/calculator/diabetes-risk-score-type-2'),
    numericInput('Age', 'Age',25, min = 0, step = 1),
    radioButtons('Sex', 'Gender', c('Male'=0,'Female'=-0.879)),
    radioButtons('RxHTN', 'Do you take any hypertension medications?', c('No'=0,'Yes'=1.222)),
    radioButtons('RxSTR', 'Do you take any steriod medications?', c('No'=0,'Yes'=2.191)),
    radioButtons('FMH', 'Does your family have a history of diabities?',
                 c('No first degree family members with diabities'=0,
                   'A parent OR sibling has diabities'=0.728,
                   'A parent AND sibling has diabities'=0.753)),
    radioButtons('Smoker', 'Are you a smoker?',
                 c('Non-smoker'=0,
                   'Used to smoke'=-0.218,
                   'Currently smoke'=0.855)),
    submitButton('Diabetes Risk !!'),
    
    h3('Waist-Hip Ratio(WHR)'),
    p('A waist-hip measurement is the ratio of the circumference of your waist to that of your hips.'),
    
    numericInput(
      'waist',
      'Waist in centi-meter(cm)',
      0,
      min = NA,
      max = NA,
      step = NA
    ),
    
    numericInput(
      'hip',
      'Hip in centi-meter(cm)',
      0,
      min = NA,
      max = NA,
      step = NA
    ),
    
    submitButton('Your WHR'),
    
    h3('Waist-to-Height Ratio'),
    p('A waist-to-height measurement is the ratio of the circumference of your waist to that of your heights.'),
    
    numericInput(
      'waist1',
      'Waist in centi-meter(cm)',
      0,
      min = NA,
      max = NA,
      step = NA
    ),
    
    numericInput(
      'height1',
      'Height in centi-meter(cm)',
      0,
      min = NA,
      max = NA,
      step = NA),
    
    submitButton('Your WHtR'),
    
    h5('Note: WHR and WHtR are more accurate than BMI.')
    
    ),
  
  mainPanel(
    h3('Result of BMI Measurement'),
    
    h4('Your weight in kg'),
    verbatimTextOutput("weight"),
    
    h4('Your height in cm'),
    verbatimTextOutput("height"),
    
    h4('Your BMI'),
    verbatimTextOutput("BMI"),
    
    h4('Your Diabities Risk Factor (as a percentage) is :'),
    verbatimTextOutput('DiabetesRisk'),
    
    h3('Result of WHR Measurement'),
    
    h4('Your waist in centi-meter(cm)'),
    verbatimTextOutput("waist"),
    
    h4('Your hip in centi-meter(cm)'),
    verbatimTextOutput("hip"),
    
    h4('Your WHR'),
    verbatimTextOutput("WHR"),
    
    h3('Result of WHtR Measurement'),
    
    h4('Your waist in centi-meter(cm).'),
    verbatimTextOutput("waist1"),
    
    h4('Your height in centi-meter(cm).'),
    verbatimTextOutput("height1"),
    
    h4('Your WHtR'),
    verbatimTextOutput("WHtR")
    
  )
  ))