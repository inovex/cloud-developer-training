package de.inovex.training.whiskystore.orders;

public class ValidTill {

    private Integer month;

    private Integer year;

    public Integer getMonth() {
        return month;
    }

    public Integer getYear() {
        return year;
    }

    public void setMonth(Integer month) {
        this.month = month;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    @Override
    public String toString() {
        return "ValidTill{" +
                "month=" + month +
                ", year=" + year +
                '}';
    }
}
