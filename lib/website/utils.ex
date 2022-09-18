defmodule Website.Utils do
  def date_to_string(date) do
    "#{month_to_string(date.month)} #{date.day}, #{date.year}"
  end

  def month_to_string(month) do
    case month do
      1 -> "January"
      2 -> "February"
      3 -> "March"
      4 -> "April"
      5 -> "May"
      6 -> "June"
      7 -> "July"
      8 -> "August"
      9 -> "September"
      10 -> "October"
      11 -> "November"
      12 -> "December"
    end
  end
end
