### ---- Classification Summary Function ----
classificationsummary = function(predict_label, actual_label, true_value, false_value) {
  true_positive <- sum((predict_label == true_value) * (actual_label == true_value))
  false_positive <- sum((predict_label == true_value) * (actual_label == false_value))
  true_negative <- sum((predict_label == false_value) * (actual_label == false_value))
  false_negative <- sum((predict_label == false_value) * (actual_label == true_value))
  total <- true_positive + false_positive + true_negative + false_negative
  accuracy <- (true_positive + true_negative) / total
  sensitivity <- true_positive / (true_positive + false_negative)
  specificity <- true_negative / (true_negative + false_positive)
  precision <- true_positive / (true_positive + false_positive)
  F1score <- 2*((precision*sensitivity)/(precision+sensitivity))
  confusion_matrix <- matrix(c(true_positive, false_positive, false_negative, true_negative), 2, 2)
  colnames(confusion_matrix) <- c("Predicted True", "Predicted False")
  rownames(confusion_matrix) <- c("Actual True", "Actual False")
  return(list(true_positive = true_positive,
              false_positive = false_positive,
              true_negative = true_negative,
              false_negative = false_negative,
              total = total,
              confusion_matrix = confusion_matrix,
              accuracy = accuracy,
              sensitivity = sensitivity,
              specificity = specificity,
              precision = precision,
              F1score = F1score ))
}