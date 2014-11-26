# Server App.
#measure body mass index

BMI <- function(weight, height) {
  
  #compute bmi
  heightSqr <- (height / 100) ^ 2
  BMI <- weight / heightSqr
  
  p <- paste0("BMI: ", BMI)
  print(p)
  #filter out weight quality based on bmi
  if (BMI < 18.5) {
    print("According to Health authorities you are underweight")
  }
  else if (BMI >= 18.5 && BMI <= 25) {
    print("According to Health authorities your weight is ideal")
  }
  else if (BMI > 25 && BMI <= 30) {                
    print("According to Health authorities you are overweight")
  }
  else if (BMI > 30) {
    print("According to Health authorities your are obese")
  }
}

bmi.1 <- function(weight, height) {
  
  #compute bmi
  heightSqr <- (height / 100) ^ 2
  BMI <- weight / heightSqr
  return(BMI)
}  
# Function to calculate BMI Risk
BMIRisk <- function(weight, height) {
  BMI <- bmi.1(weight, height)
  risk <- 0
  
  if(BMI >= 30 ) risk <- 2.518
  else if(BMI >= 27.5) risk <- 1.97
  else if(BMI >= 25) risk <- 0.699
  
  risk
}

# Function to Calculate Diabetes Risk

Diabetes.risk <- function(Sex, RxHTN, RxSTR, Age, bmi, FMH, Smoker)
{
  Terms <- 6.322 - Sex - RxHTN - RxSTR - 0.063*Age - bmi - FMH - Smoker
  100 / (1 + exp(Terms))
}



#measure Waist Hip Ratio
WHR <- function(waist, hip) {
  
  #compute Waist Hip Ratio
  WHR <- waist / hip
  p <- paste0("Your waist size is ", round(WHR * 100), "% of your hip size.")
  print(p)
  
  # male WHR
  #filter out cardiovascular health problems for male based on WHR
  if (WHR < .9) {
    print("Male: Low risk of cardiovascular health problems.")
  }
  if (WHR >= .9 && WHR <= .99) {
    print("Male: Moderate risk of cardiovascular health problems.")
  }
  if (WHR > .99) {
    print("Male: High risk of cardiovascular health problems.")
  }
  
  #female WHR
  #filter out cardiovascular health problems for female based on WHR
  if (WHR < .8) {
    print("Female: Low risk of cardiovascular health problems.")
  }
  if (WHR >= .8 && WHR <= .89) {
    print("Female: Moderate risk of cardiovascular health problems")
  }
  if (WHR >= .9) {
    print("Female: High risk of cardiovascular health problems")
  }
}

#measure Weight to Height Ratio (WHtR)
WHtR <- function(waist1, height1) {
  
  #compute Weight to Height Ratio
  WHtR <- round((waist1 / height1) * 100)        
  p <- paste0("Your waist circumference is ", WHtR, "% of your height.")
  print(p)
  
  #classify life expectancy based on WHtR
  if (WHtR <= 50) {
    print("This can help you to increase your life expectancy.")
  }
  if (WHtR > 50) {
    print("Your WHtR is not ideal.")
  }
}

shinyServer(
  function(input, output) {
    output$weight <- renderPrint({input$weight})
    output$height <- renderPrint({input$height})
    output$height1 <- renderPrint({input$height1})
    output$waist <- renderPrint({input$waist})
    output$waist1 <- renderPrint({input$waist1})
    output$hip <- renderPrint({input$hip})
    
    #call required function
    output$BMI <- renderPrint({BMI(input$weight, input$height)})   
    output$WHR <- renderPrint({WHR(input$waist, input$hip)})
    output$WHtR <- renderPrint({WHtR(input$waist1, input$height1)})
    output$DiabetesRisk <- renderPrint({round(Diabetes.risk(
      Sex=as.numeric(input$Sex), RxHTN=as.numeric(input$RxHTN), 
      RxSTR=as.numeric(input$RxSTR), Age=input$Age, bmi=BMIRisk(input$weight, input$height),
      FMH = as.numeric(input$FMH), Smoker = as.numeric(input$Smoker)),2)})
  }
)