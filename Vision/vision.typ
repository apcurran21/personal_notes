// styling

// /*
#set terms(
  separator: "\n- ",
  indent: 6pt, 
)

#set math.equation(
  numbering: "(1)",
  supplement: [Eq.],
)

#set text( 
  font: "New Computer Modern",
  // size: 7pt,
)
// */


/*
// "latex" look from typst website
#set page(margin: 1.75in)
#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono")
#show par: set block(spacing: 0.55em)
#show heading: set block(above: 1.4em, below: 1em)
*/




= Vision Notes

Contains personal notes on _Fisher Information_ and other related/necessary concepts.

== Fisher Information (FI)

From the Simoncelli lecture, the Fisher Information $I(s)$ of a given stimulus $s$ is the second-order expansion of the expected negative log likelihood. 

=== Definition
$ I(s) = - #sym.EE [ ( partial^2 log p(r|s) ) / ( partial s^2 ) ] $

=== Intuition

It is handy to think about Fisher information through the lense of perception studies, which use this technique a lot.
For our scenario, we can consider an experiment where we wish to find thresholds around human perception of brightness.
For example, how much must we increase the brightness value of a light in order for us to perceive the change?
The light is the *stimulus* - it is the input from the outside world that we receive. 
Given this stimulus, our eyes, brain, etc will produce a *response*.
There is not a one-to-one mapping of stimulus to response.
Due to biological noise, a given stimulus value will always correspond with a *response distribution*. 
In other words, a given stimulus could produce a range of response values within our internals, but these values will follow some distribution with a certain mean, variance, etc.
It is then helpful to think of this function between stimuli (on the x-axis) and response (on the y-axis) with an subsequent function $f(s)$ applied. 
For example, we will use $f$ as the mean of the response corresponding with the stimulus $s$.  

We are not particularly interested in the response itself hoewever - that part is internal to the brain, and hard to study. 
We care about the _estimate_ of the stimulus that we make, which is based on the internal response.
To summarize, our brain follows the following process:
+ Eyes receive the stimulus and transmit the signal to the brain.
+ Brain creates a response from this stimulus signal. This is a stochastic process - the same stimulus value could produce many response values. Even more importantly, *multiple stimuli values could produce the same response value*.
+ Based on the shape, mean, etc of the response, the brain must make an estimation of what stimulus value is most likely to have produced that response.
	- This can be tricky! We note above that different stimulus values might produce the same response value in the brain. The challenge is finding how different these stimulus values have to be in order for us to *discriminate* between them reliably (ie, with some probability).

*Side Note: * I can think of two different ways to increase the odds of a subject discriminating between two stimuli.
+ Increasing the "distance" between the stimuli. Responses to stimuli are distributions with some mean value. 
+ Increasing the number of samples taken from the response distribution. Thiscan come from having a longer exposure to the stimulus - for example, viewing a light for a longer period of time allows our brain to take more samples from the response distribution corresponding with the brightness level of the light. 
	- The idea of having more exposure is pretty intuitive from a statistical standpoint. It is equivalent to increasing the sample size, which we know will produce more accurate estimations of the mean, variance, etc of a distribution.

The point of the above paragraph is to say that the brain has to rely on the mean, variance, etc of 

Note that this second derivative expression gives us the precision of an estimator.

=== Alternative Definitions
_Probability and Statistics_ describes the FI as, "one property of a distribution that can be used to measure how much information one is likely to obtain from a random variable or a random sample." It receives a primary definition in a slightly different (more generalized) format:
$ I(theta) = EE_(theta){[lambda'(X|theta)]^2} $ <FI_1>
where $lambda(x|theta)$ is the log probability of a random variable $X$, that is
$ lambda(x|theta) = log f(x|theta) $ 
for $X$'s pdf $f(x|theta)$ with parameter $theta$.
It is further assumed that $lambda(x|theta)$ is twice differentiable with respect to $theta$.
This textbook definition is completely equivalent to the one used in the NYU lecture. 
The differences in formatting comes from the fact that the NYU lecture is focused on psychophysics and perception, while the textbook looks to generalize the FI to any application.

If $f$ is indeed a pdf, then the FI can be calculated as
$ I(theta) = integral_S [lambda'(x|theta)]^2 f(x|theta) d x. $
$X$ takes on values in the sample space $S$, which is why we take the integral over $S$ when calculating the expectation.
Note that $f$ can also be pmf (when $X$ is discrete). In this case, we just take the sum over all $x$ in $S$ when calculating the expectation. 

We can also express the FI in these two ways, which are equivalent to the above definition:
$ I(theta) = -EE_theta [lambda''(X|theta)] $ <FI_second_deriv>
$ I(theta) = op("Var")_theta [lambda'(X|theta)] $ <FI_variance>

*Proof.* #h(1em) For clarity, here are all of the conditions/assumptions required for the previous definitions and this proof:
- $X$ is a random variable, with a distribution that depends on a parameter $theta$ that takes values in an open interval $Omega$ of the real line.
- $f(x|theta)$ is the probability density function of $X$. The same definitions and proof hold if $f$ is a mass function, but for simplicity we'll show just the continuous case.
- The set of $x in X$ such that $f(x|theta) > 0$ is the same for all $theta$.
- $lambda(x|theta) = log f(x|theta)$ is twice differentiable as a function of $theta$.
- The first and second derivatives of $integral_S f(x|theta) d x$ with respect to $theta$ can be calculated by reversing the order of integration and differentiation (ie. differentiating $f$, then taking the integral of that expression).

We know that $integral_S f(x|theta) d x = 1$ for all $theta in Omega$.
This means that if the integral expression on the left-hand side of the equation were written as a function of $theta$, it would be a constant function of 1. 
Therefore, the result of differentiating this expression with respect to $theta$ is 0.
We will assume that we can take the derivative inside the integral sign and receive
$ integral_S f'(x|theta) d x = 0 "for" theta in Omega. $ <f_prime>
We also made the assumption that we can take the second derivative with respect to $theta$ inside of the integral, so we receive
$ integral_S f''(x|theta) d x = 0 "for" theta in Omega. $ <f_prime_prime>
The derivative of $lambda$ is
$ d / ( d x ) ( lambda(x|theta) ) &= d / ( d x ) ( log (f(x|theta)) ) \
&= 1 / f(x|theta) dot d / ( d x ) (f(x|theta)) \
&= (f'(x|theta)) / f(x|theta). $
Knowing this, we can write the following expectation as
$ EE_theta [lambda'(X|theta)] &= integral_S lambda'(x|theta)f(x|theta) d x \
&= integral_S ((f'(x|theta)) / f(x|theta)) dot f(x|theta) d x \
&= integral_S f'(x|theta) d x . $
Therefore it follows from @f_prime that
$ EE_theta [lambda'(X|theta)] = 0 . $ <E_L_prime>
Note that one formula for variance is $op("Var")(Y) = EE [Y^2] - EE[Y]^2$ where $mu$ is the mean of $Y$. 
We want to show that the expression $op("Var")_theta [lambda'(X|theta)]$ is equivalent to the fisher information. 
$ op("Var")_theta [lambda'(X|theta)] &= EE {[lambda'(X|theta)]^2} - EE[lambda'(X|theta)]^2 \ 
&= EE {[lambda'(X|theta)]^2} - (0)^2 & #[@E_L_prime] \
&= EE {[lambda'(X|theta)]^2}. $
Therefore @FI_variance is a valid definition of the FI. To show that @FI_second_deriv is one as well, we need to take the second derivative of $lambda(X|theta)$. We'll make use of the quotient rule, listed here for reference:
$ d / (d x) ( f(x) / g(x) ) = ( g(x) dot f'(x) - f(x) dot g'(x) ) / g(x)^2 $
The second derivative of $lambda$ is then
$ lambda''(x|theta) &= d / (d x) (lambda'(x|theta)) \
&= d / (d x) ((f'(x|theta)) / f(x|theta)) \ 
&= ( f(x|theta) dot f''(x|theta) - f'(x|theta) dot f'(x|theta) ) / [ f(x|theta) ]^2 \ 
// &= ( f(x|theta) dot f''(x|theta) - [ f'(x|theta) ]^2 ) / [ f(x|theta) ]^2 $
&= ( f(x|theta) dot f''(x|theta) ) / [ f(x|theta) ]^2 - [ f'(x|theta) ]^2 / [ f(x|theta) ]^2 \ 
&= ( f''(x|theta) ) / f(x|theta) - [ lambda'(x|theta) ]^2 . $
We now want to show that the expression $-EE_theta[lambda''(X|theta)]$ equals our original definition of the Fisher information, @FI_1.
$ -EE_theta [lambda''(X|theta)] &= -EE_theta [( f''(x|theta) ) / f(x|theta) - [ lambda'(x|theta) ]^2] \ 
&= -EE_theta [( f''(x|theta) ) / f(x|theta) ] - EE_theta [ -lambda'(x|theta) ]^2 \ 
&= integral_S [ ( f''(x|theta) ) / f(x|theta) dot f(x|theta) d x ] + EE_theta [ lambda'(x|theta) ]^2] \ 
&= integral_S [ f''(x|theta) d x ] + EE_theta [ lambda'(x|theta) ]^2] \ 
&= (0) + EE_theta [ lambda'(x|theta) ]^2] & #[@f_prime_prime] \ 
&= EE_theta [ lambda'(x|theta) ]^2] $
Therefore @FI_second_deriv is also a valid definition of the FI.
#h(1fr) #sym.square.filled.small

=== Intuition Behind Alt. Definitions
The first thing to note is that @FI_second_deriv is the same exact expression as the one taught in the NYU lecture.
Often, it is easier to determine and/or compute the FI using this equation compared to the other two listed here. 




=== Tools
Fisher information allows us to place a bound on the "precision" of unbiased estimators. This is known as the *Cramer-Rao* bound:
$ sigma^2 (s) #sym.gt.eq 1 / I(s) $
When dealing with perception, this property is useful for providing a bound on discrimination $D$:
$ D(s) #sym.lt.eq sqrt(I(s)) $

== Efficient Sensory Encoding and Bayesian Inference with Heterogeneous Neural Populations

=== Overview

=== Notation & Equations
/ $bold(N)$ : the population size, describes a set of _N_ neurons
/ $bold(n)$ : index into the current neuron (eg: "Assume the number of spikes emitted in a given time interval by the nth neuron ...")
/ $bold(h_(n)(s))$ : the tuning function of the $n$th neuron
/ $bold(R)$ : the total expected spike rate of the neuron population

*Assuming* the number of spikes emitted in a given time interval by the $n$th neuron is a sample from an independent *Poisson* process, with a *mean rate* determined by its tuning function $h_(n)(s)$, the _probability_ distribution of the population response is written as:

$ p(*r*|s) = limits(#sym.product)_(n=1)^(N) (h_(n)(s)^(r_(n)) e^(-h_(n)(s))) / (r_(n)#sym.excl) $

