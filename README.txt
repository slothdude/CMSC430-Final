Marc Eastman
I pledge on my honor that I have not given or received any unauthorized assistance
on this examination or assignment


OVERVIEW

This project is a compiler from scheme to LLVM. Top level takes a scheme program
as a list, and then matches on the scheme grammar to convert to a sub-grammar of
the language. Desugar takes the grammar output from that and desugars it to an
even smaller sub-grammar shown below:
e =   (let ([x e] ...) e)
    | (lambda (x ...) e)
    | (lambda x e)
    | (apply e e)
    | (e e ...)
    | (prim op e ...)
    | (apply-prim op e)
    | (if e e e)
    | (set! x e)
    | (call/cc e)
    | x
    | (quote datum)
where 'op' is a prim defined in section PRIMS below. Then 'set!' is removed from
the language and replaced with 'make-vector' and 'vector-set!' and 'vector-ref.'
After static single assignment, the code is ANF converted and then CPS converted.
All of the variadic functions are transformed into non-variadic functions, the
language is changed to a list of first order procedures and this list gets
converted to LLVM to produce an executable using clang 3.9. The evaluated code
produces the same result at the beginning, the end, and each intermediary step.


PRIMS
= :: int -> int ...+ -> boolean
true if all numbers are equal (must be atleast 2)

> :: int -> int ...+ -> boolean
true if numbers are in decreasing order

>= :: int -> int ...+ -> boolean
true if numbers are in decreasing-or-equal order

< :: int -> int ...+ -> boolean
true if numbers are in increasing order

<= :: int -> int ...+ -> boolean
true if numbers are in increasing-or-equal order

+ :: int ... -> int
adds all numbers starting from 0

- :: int ...+ -> int
subtracts all numbers starting from 0

* :: int ... -> int
multiplies all numbers starting from 1

/ :: int ...+ -> int
divides all numbers starting from 1

null? :: x -> boolean
true if x is null

cons :: x -> (list x) -> (list x)
cons :: x -> x -> (pair x)
if arg2 is a list, appends arg1 to the front of that list. Otherwise makes a pair

car :: (list x) -> x
returns the head of the list

cdr :: (list x) -> (list x)
returns the tail of the list

list :: x ... -> (list x)
adds all arguments to a list starting from '()

length :: (list x) -> int
returns the length of the list

member :: x -> (list x) -> boolean
true if x is contained in the list

memv :: x -> (list x) -> boolean
true if x is contained in the list but checks using eqv?

map :: proc -> (list x) -> (list x)
applies proc to each element of the list

append :: (list x) -> (list x) ...+ -> (list x)
appends the lists together into 1 list

vector? :: x -> boolean
true if x is a vector

vector :: x ... -> vector
adds all arguments to a vector starting from #()

make-vector :: int -> vector
returns a vector of arg1 size

vector-ref :: vector -> int -> x
returns the arg2's element of arg1

vector-set! :: vector -> int -> x -> void
updates the arg2 position of arg1 to contain arg3

vector-length :: vector -> int
returns the number of elements in the vector

set :: x ... -> set
returns a set of all the arguments

set->list :: set -> list
pretty self explanatory...

list->set :: list -> set
removes all duplicates in the list by adding the elements to a set

set-add :: set -> x -> set
returns a set with arg2 added

set-union :: set -> set ... -> set
combines all sets into a single set

set-count :: set -> int
returns number of elements in the set

set-remove :: set -> x -> set
returns a set where arg2 has been removed from arg1

hash :: x -> y ... -> hash
must have even number of arguments, returns a hash where each key is mapped to the value following.

hash? :: x -> boolean
true if x is a hash

hash-ref :: hash -> x -> [proc] -> y
returns the value for key arg2. arg3 is invoked if key isn't found.
Default value for arg3: (lambda () (raise (make-exn:fail:contract ....)))

hash-set :: hash -> x -> y -> hash
returns a hash where key x is set to value y

hash-count :: hash -> int
returns number of keys in arg

hash-keys :: hash -> list
returns list of keys in hash

hash-has-key? :: hash -> x -> boolean
returns true if arg1 contains arg2 as a key

list? :: x -> boolean
true if arg1 is a list

void? :: x -> boolean
true if arg1 is void

promise? :: x -> boolean
true if arg1 is a promise

procedure? :: x -> boolean
true if arg1 is a procedure

integer? :: x -> boolean
true if arg1 is an int

error :: x ...+ -> y
combines all args into a list which is output as part of the error

void :: x ... -> void
all arguments are ignored, returns void

halt :: x ... -> y
as soon as halt is invoked, everything stops and nothing more is executed

eq? :: x -> y -> boolean
true if arg1 and arg2 are the same object

eqv? :: x -> y -> boolean
same as 'eq?' unless otherwise specified for a specific type

equal? :: x -> y -> boolean
same as 'eqv?' unless otherwise specified for a specific type

not :: x -> boolean
true if arg1 is false


RUN TIME ERRORS

I tried to make a divide by zero error be thrown during the prim evaluation but
it threw a divide by zero for me so I kind of moved on, only to run out of time later


BUILT IN DATA TYPES

I made strings that just use a tag. Mystrings are defined as lists of
chars, which tag a quoted symbol like (char 'c). Nested mystring are not
permitted. Predicates (mystring? s) and (mychar? c) were added to utils.rkt right
 before datum definitions. examples:
> (mychar? '(char 'a))
#t
> (mystring? '(string (char 'a)(char 'b)))
#t
> (mystring? '(string (string (char 'a))(char 'b)))
#f

Functions allocated to 'mystring' and 'mychar':

string-append :: mystring -> mystring
appends all mystrings together. Example:
> (top-level '(string-append (string (char 'h)(char 'e)) (string (char 'l)
              (char 'l)(char 'o))(string)(string)))
'(string (char 'h) (char 'e) (char 'l) (char 'l) (char 'o))

string->list :: mystring -> (List mychar)
converts a mystring to a list of mychars. Example:
> (top-level '(string->list(string (char 'h) (char 'e) (char 'l) (char 'l) (char 'o))))
'((char 'h) (char 'e) (char 'l) (char 'l) (char 'o))

string-ref :: mystring -> int -> mychar
returns the mychar at arg2's index in arg1. Example:
> (top-level '(string-ref (string-append (string (char 'h))
              (string (char 'e)(char 'l)(char 'l))) 2))
'(char 'l)

substring :: mystring -> int -> int -> mystring
returns the portion of arg1 from arg2 inclusive to arg3 exclusive. Example:
> (top-level '(substring (string (char 'h) (char 'e) (char 'l) (char 'l) (char 'o)) 2 4))
'(string (char 'l) (char 'l))

Unfortunately, these representations of strings and chars that I made are
unable to be used by other parts of the program because I was unable to transform
my representations of strings and chars back into the scheme form for strings and chars.


BOEHM GARBAGE COLLECTOR

I did not attempt implementation of the boehm garbage collector
