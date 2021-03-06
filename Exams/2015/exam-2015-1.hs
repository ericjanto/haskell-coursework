-- Informatics 1 Functional Programming
-- December 2015
-- SITTING 1 (09:30 - 11:30)

import Test.QuickCheck( quickCheck, 
                        Arbitrary( arbitrary ),
                        oneof, elements, sized, (==>), Property )
import Control.Monad -- defines liftM, liftM3, used below
import Data.List
import Data.Char

-- Question 1

-- 1a

p :: [Int] -> Int
p xs = 1 + mod (div (sum [x | x <- xs, x > 0]) 60) 12

test_p =  p [] == 1 &&
          p [-30,-20] == 1 &&
          p [20,-30,30,14,-20] == 2 &&
          p [200,45] == 5 &&
          p [60,-100,360,-20,240,59] == 12 &&
          p [60,-100,360,-20,240,60] == 1
-- 1b

q :: [Int] -> Int
q xs = 1 + mod (div (getSum xs) 60) 12
    where
      getSum [] = 0
      getSum (x:xs) | x > 0     = x + getSum xs
                    | otherwise = getSum xs

test_q =  q [] == 1 &&
          q [-30,-20] == 1 &&
          q [20,-30,30,14,-20] == 2 &&
          q [200,45] == 5 &&
          q [60,-100,360,-20,240,59] == 12 &&
          q [60,-100,360,-20,240,60] == 1

-- 1c

r :: [Int] -> Int
r = (+1) . (`mod` 12) . (`div` 60) . foldr (+) 0 . filter (>0)

prop_pqr :: [Int] -> Bool
prop_pqr xs = p xs == q xs && q xs == r xs

test_pqr = quickCheck prop_pqr

-- Question 2

-- 2a

f :: String -> String
f [] = []
f xs = [x | (x,y) <- zip xs $ tail xs, x /= y] ++ [last xs]

test_f =  f "Tennessee" == "Tenese" &&
          f "llama" == "lama" &&
          f "oooh" == "oh" &&
          f "none here" == "none here" &&
          f "nNnor hEere" == "nNnor hEere" &&
          f "A" == "A" &&
          f "" == ""

-- 2b

g :: String -> String
g [] = []
g [x] = [x]
g (x:y:xs) | x /= y = x : g (y:xs)
           | otherwise = g (y:xs)

test_g =  g "Tennessee" == "Tenese" &&
          g "llama" == "lama" &&
          g "oooh" == "oh" &&
          g "none here" == "none here" &&
          g "nNnor hEere" == "nNnor hEere" &&
          g "A" == "A" &&
          g "" == ""

prop_fg s = g s == f s
test_fg = quickCheck prop_fg
                         
-- Question 3

data Regexp = Epsilon
            | Lit Char
            | Seq Regexp Regexp
            | Or Regexp Regexp
        deriving (Eq, Ord)

-- turns a Regexp into a string approximating normal regular expression notation

showRegexp :: Regexp -> String
showRegexp Epsilon = "e"
showRegexp (Lit c) = [toUpper c]
showRegexp (Seq r1 r2) = "(" ++ showRegexp r1 ++ showRegexp r2 ++ ")"
showRegexp (Or r1 r2) = "(" ++ showRegexp r1 ++ "|" ++ showRegexp r2 ++ ")"

-- for checking equality of languages

equal :: Ord a => [a] -> [a] -> Bool
equal xs ys = sort xs == sort ys

-- For QuickCheck

instance Show Regexp where
    show  =  showRegexp

instance Arbitrary Regexp where
  arbitrary = sized expr
    where
      expr n | n <= 0 = oneof [elements [Epsilon]]
             | otherwise = oneof [ liftM Lit arbitrary
                                 , liftM2 Seq subform subform
                                 , liftM2 Or subform subform
                                 ]
             where
               subform = expr (n `div` 2)



r1 = Seq (Lit 'A') (Or (Lit 'A') (Lit 'A'))   -- A(A|A)
r2 = Seq (Or (Lit 'A') Epsilon)
         (Or (Lit 'A') (Lit 'B'))             -- (A|e)(A|B)
r3 = Seq (Or (Lit 'A') (Seq Epsilon
                            (Lit 'A')))
         (Or (Lit 'A') (Lit 'B'))             -- (A|(eA))(A|B)
r4 = Seq (Or (Lit 'A')
             (Seq Epsilon (Lit 'A')))
         (Seq (Or (Lit 'A') (Lit 'B'))
              Epsilon)                        -- (A|(eA))((A|B)e)
r5 = Seq (Seq (Or (Lit 'A')
                  (Seq Epsilon (Lit 'A')))
              (Or Epsilon (Lit 'B')))
         (Seq (Or (Lit 'A') (Lit 'B'))
              Epsilon)                        -- ((A|(eA))(e|B))((A|B)e)
r6 = Seq (Seq Epsilon Epsilon)
         (Or Epsilon Epsilon)                 -- (ee)(e|e)

-- 3a

language :: Regexp -> [String]
language (Epsilon) = [""]
language (Lit a) = [[a]]
language (Seq a b) = language a ++ language b
language (Or a b) = language a ++ language b

-- 3b

simplify :: Regexp -> Regexp
simplify (Or a b) | a == a = (Lit a)
-- :(