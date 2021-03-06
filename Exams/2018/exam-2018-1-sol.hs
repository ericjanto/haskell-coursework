-- Informatics 1 Functional Programming
-- December 2018
-- SITTING 1 (09:30 - 11:30)

import Test.QuickCheck
import Control.Monad
import Data.Char

-- Question 1

-- 1a

f :: String -> Int
f cs = sum [ n | (c,n) <- zip cs [0..], isUpper c ]

test_1a =
  f "" == 0 &&
  f "no capitals here" == 0 &&
  f "Positions start from 0" == 0 &&
  f "ALL CAPS" == 25 &&
  f "I Love Functional Programming" == 27 &&
  f "1oTs & LoT5 of Num63r5" == 33

-- 1b

g :: String -> Int
g cs = g' cs 0

g' :: String -> Int -> Int
g' [] n = 0
g' (c:cs) n | isUpper c = n + g' cs (n+1)
            | otherwise = g' cs (n+1)

test_1b =
  g "" == 0 &&
  g "no capitals here" == 0 &&
  g "Positions start from 0" == 0 &&
  g "ALL CAPS" == 25 &&
  g "I Love Functional Programming" == 27 &&
  g "1oTs & LoT5 of Num63r5" == 33

prop_fg :: String -> Bool
prop_fg cs = f cs == g cs

-- Question 2

-- 2a

p :: [(Int,Int)] -> Bool
p xs = sum [m^2 | (m,_) <- xs] > product [n | (_,n) <- xs, odd n]

test_2a =
  p [] == False &&
  p [(4,5),(1,3)] == True &&
  p [(4,5),(1,2),(2,7)] == False &&
  p [(-1,3),(1,1)] == False &&
  p [(1,2),(2,3),(3,5)] == False &&
  p [(2,2),(2,3),(3,5)] == True

-- 2b

q :: [(Int,Int)] -> Bool
q xs = q1 xs > q2 xs

q1 :: [(Int,Int)] -> Int
q1 [] = 0
q1 ((m,_):xs) = m^2 + q1 xs

q2 :: [(Int,Int)] -> Int
q2 [] = 1
q2 ((_,n):xs) | odd n     = n * q2 xs
              | otherwise = q2 xs

test_2b =
  q [] == False &&
  q [(4,5),(1,3)] == True &&
  q [(4,5),(1,2),(2,7)] == False &&
  q [(-1,3),(1,1)] == False &&
  q [(1,2),(2,3),(3,5)] == False &&
  q [(2,2),(2,3),(3,5)] == True

-- 2c

r :: [(Int,Int)] -> Bool
r xs = (foldr (+) 0 (map ((^2).fst) xs)) > (foldr (*) 1 (filter odd (map snd xs)))

test_2c =
  r [] == False &&
  r [(4,5),(1,3)] == True &&
  r [(4,5),(1,2),(2,7)] == False &&
  r [(-1,3),(1,1)] == False &&
  r [(1,2),(2,3),(3,5)] == False &&
  r [(2,2),(2,3),(3,5)] == True

prop_pqr :: [(Int,Int)] -> Bool
prop_pqr xs = p xs == q xs && q xs == r xs

-- Question 3

data Tree a = Lf a | Tree a :+: Tree a
  deriving (Eq, Show)

instance Arbitrary a => Arbitrary (Tree a) where
  arbitrary = sized gen
    where
    gen 0 = liftM Lf arbitrary
    gen n | n>0 =
      oneof [liftM Lf arbitrary,
             liftM2 (:+:) tree tree]
      where
      tree = gen (n `div` 2)

-- 3a

right :: Tree a -> Bool
right (Lf x)         =  True
right (Lf x :+: xt)  =  right xt
right (_ :+: _)      =  False

prop_right :: Bool
prop_right
  =   right (Lf 1)                                 ==  True
  &&  right (Lf 1 :+: (Lf 2 :+: (Lf 3 :+: Lf 4)))  ==  True 
  &&  right ((Lf 1 :+: Lf 2) :+: (Lf 3 :+: Lf 4))  ==  False
  &&  right (Lf "a" :+: (Lf "b" :+: Lf "c"))       ==  True
  &&  right ((Lf "a" :+: Lf "b") :+: Lf "c")       ==  False

-- 3b

leaves :: Tree a -> [a]
leaves (Lf x)       =  [x]
leaves (xt :+: yt)  =  leaves xt ++ leaves yt

prop_leaves :: Bool
prop_leaves
  =   leaves (Lf 1)                                 ==  [1]
  &&  leaves (Lf 1 :+: (Lf 2 :+: (Lf 3 :+: Lf 4)))  ==  [1,2,3,4]
  &&  leaves ((Lf 1 :+: Lf 2) :+: (Lf 3 :+: Lf 4))  ==  [1,2,3,4]
  &&  leaves (Lf "a" :+: (Lf "b" :+: Lf "c"))       ==  ["a","b","c"]
  &&  leaves ((Lf "a" :+: Lf "b") :+: Lf "c")       ==  ["a","b","c"]

-- 3c

shift :: Tree a -> Tree a
shift (Lf x)                =  Lf x
shift (Lf x :+: xt)         =  Lf x :+: shift xt
shift ((xt :+: yt) :+: zt)  =  shift (xt :+: (yt :+: zt))

prop_shift :: Bool
prop_shift
  =   shift (Lf 1)
        ==  (Lf 1)
  &&  shift (Lf 1 :+: (Lf 2 :+: (Lf 3 :+: Lf 4)))
        ==  (Lf 1 :+: (Lf 2 :+: (Lf 3 :+: Lf 4)))
  &&  shift ((Lf 1 :+: Lf 2) :+: (Lf 3 :+: Lf 4))
        ==  (Lf 1 :+: (Lf 2 :+: (Lf 3 :+: Lf 4)))
  &&  shift (Lf "a" :+: (Lf "b" :+: Lf "c"))
        ==  (Lf "a" :+: (Lf "b" :+: Lf "c"))
  &&  shift ((Lf "a" :+: Lf "b") :+: Lf "c")
        ==  (Lf "a" :+: (Lf "b" :+: Lf "c"))

prop_tree :: Eq a => Tree a -> Bool
prop_tree xt  =  right (shift xt) && leaves xt == leaves (shift xt)

main
  =   quickCheck test_1a
  >>  quickCheck test_1b
  >>  quickCheck test_2a
  >>  quickCheck test_2b
  >>  quickCheck test_2c
  >>  quickCheck prop_fg
  >>  quickCheck prop_pqr
  >>  quickCheck prop_right
  >>  quickCheck prop_leaves
  >>  quickCheck prop_shift
  >>  quickCheck prop_int
  >>  quickCheck prop_string
  where
  prop_int    :: Tree Int -> Bool
  prop_int    =  prop_tree
  prop_string :: Tree String -> Bool
  prop_string =  prop_tree