\name{\%>\%}
\alias{\%>\%}
\alias{Row}
\alias{Range}

%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Yet Another Pipe Operator
}
\description{
A pipe operator the avoids NSE combining ideas from magrittr and purrr and helper functions.
}
\usage{
left \%>\% right
Row(x)
Range(x)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{left}{
Any R object.
}
  \item{x, right}{
One of a
\describe{
\item{function}{returns right(left)}
\item{formula}{see details}
\item{length-one integer vector}{left[[right]]}
\item{length-one character vector}{left[[right]] or slot(left, right) for S4 objects}
\item{Either interger or character vector but with addtional inehritance from "Row", "Range" or both}{left[right] with inheritance from "Range", left[right, ,drop = FALSE] with inheritance from both "Range" and "Row"}}
}
}
\details{
Row and Range only add their namesake classes to their argument and return it. One used as right arguments, formulas are evaluated as follows. Only right sided formulas, that like ~x+y, are supported. The formula is evaluated in its original environment with the addition of variable .. and one variable for each named element of left, converted to a list.
}
\value{
For Range and Row, an object inheriting from Range or Row resp. For \code{\%>\%}, see arguments.
}
\author{
Antonio Picolboni}
\examples{
## See directory tests
}
