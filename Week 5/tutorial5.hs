-- Informatics 1 - Introduction to Computation
-- Functional Programming Tutorial 5
--
-- Week 5(14-18 Oct.)

module Tutorial5 where

import Data.Char
import Data.List
import Data.Ratio
import Test.QuickCheck

-- 1. Map

-- a.
doubles :: [Int] -> [Int]
doubles = map (*2)

test_doubles =
  doubles [1,2,3] == [2,4,6] &&
  doubles []      == []

-- b.        
penceToPounds :: [Int] -> [Float]
penceToPounds = map (/100) . map fromIntegral

test_pence =
  penceToPounds [] == [] &&
  penceToPounds [120,240,0] == [1.2,2.4,0]

-- c.
uppersComp :: String -> String
uppersComp = map toUpper

test_uppersComp =
  uppersComp []       == [] &&
  uppersComp "qwertz" == "QWERTZ"

-- 2. Filter
-- a.
alphas :: String -> String
alphas = filter isAlpha

alphas' xs = [ x | x <- xs, isAlpha x ]

prop_alphas :: String -> Bool
prop_alphas s = alphas s == alphas' s

test_alphas = quickCheck prop_alphas

-- b.
above :: Int -> [Int] -> [Int]
above x = filter (>x)

above' x xs = [ y | y <- xs, y > x]

prop_above :: Int -> [Int] -> Bool
prop_above x xs = above x xs == above' x xs

test_above = quickCheck prop_above

-- c.
unequals :: [(Int,Int)] -> [(Int,Int)]
unequals = filter unequal
  where
    unequal (x,y) = x == y

unequals' :: [(Int,Int)] -> [(Int,Int)]
unequals' ps = [ pair | pair@(x,y) <- ps, x == y ]

prop_unequals :: [(Int,Int)] -> Bool
prop_unequals ps = unequals ps == unequals' ps

test_unequals = quickCheck prop_unequals

-- d.
rmCharComp :: Char -> String -> String
rmCharComp ch = filter (/= ch)

rmCharComp' ch s = [c | c <- s, c /= ch]

prop_rmCharComp :: Char -> String -> Bool
prop_rmCharComp ch s = rmCharComp ch s == rmCharComp' ch s

test_rmCharComp = quickCheck prop_rmCharComp

-- 3. Comprehensions vs. map & filter
-- a.
largeDoubles :: [Int] -> [Int]
largeDoubles xs = [2 * x | x <- xs, x > 3]

largeDoubles' :: [Int] -> [Int]
largeDoubles' = map (*2) . filter (>3)

prop_largeDoubles :: [Int] -> Bool
prop_largeDoubles xs = largeDoubles xs == largeDoubles' xs 

test_largeDoubles = quickCheck prop_largeDoubles

-- b.
reverseEven :: [String] -> [String]
reverseEven strs = [reverse s | s <- strs, even (length s)]

reverseEven' :: [String] -> [String]
reverseEven' = map reverse . filter evenL
  where
    evenL s = even $ length s

prop_reverseEven :: [String] -> Bool
prop_reverseEven strs = reverseEven strs == reverseEven' strs

test_reverseEven = quickCheck prop_reverseEven

-- 4. Foldr
-- a.
andRec :: [Bool] -> Bool
andRec []     = True
andRec (x:xs) = x && andRec xs

andFold :: [Bool] -> Bool
andFold = foldr (&&) True

prop_and :: [Bool] -> Bool
prop_and xs = andRec xs == andFold xs

test_and = quickCheck prop_and

-- b.
concatRec :: [[a]] -> [a]
concatRec [] = []
concatRec (l:ls) = l ++ concatRec ls

concatFold :: [[a]] -> [a]
concatFold = foldr (++) []

prop_concat :: [String] -> Bool
prop_concat strs = concatRec strs == concatFold strs

test_concat = quickCheck prop_concat

-- c.
rmCharsRec :: String -> String -> String
rmCharsRec [] y = y
rmCharsRec _ [] = []
rmCharsRec (x:xs) y = rmCharsRec xs (rmCharComp x y)

rmCharsFold :: String -> String -> String
rmCharsFold chs str = foldr rmCharComp str chs

prop_rmChars :: String -> String -> Bool
prop_rmChars chars str = rmCharsRec chars str == rmCharsFold chars str

test_rmChars = quickCheck prop_rmChars


type Matrix = [[Rational]]

-- 5
-- a.
uniform :: [Int] -> Bool
uniform [] = True
uniform (y:xs) = and [ y == x | x <- xs ]

uniform' :: [Int] -> Bool
uniform' [] = True
uniform' (x:xs) = all (== x) xs

uniform'' :: [Int] -> Bool
uniform'' [] = True
uniform'' (x:xs) = foldr (&&) True (map (== x) xs)

prop_uniform :: [Int] -> Bool
prop_uniform xs =
  uniform xs == uniform' xs &&
  uniform xs == uniform'' xs

test_uniform = quickCheck prop_uniform

-- b.
valid :: Matrix -> Bool
valid [] = False
valid m@(x:xs) = uniform (map length m) && not (null x)

test_valid =
  valid [[],[],[]] == False &&
  valid [[1],[2]]  == True &&
  valid []         == False


-- 6.
matrixWidth :: Matrix -> Int
matrixWidth [] = error "Matrix not valid!"
matrixWidth (x:xs) = length x 

matrixHeight :: Matrix -> Int
matrixHeight [] = error "Matrix not valid!"
matrixHeight m = length m

sameDimension :: Matrix -> Matrix -> Bool
sameDimension m1 m2 = matrixWidth m1  == matrixWidth m2 &&
                      matrixHeight m1 == matrixHeight m2

plusM :: Matrix -> Matrix -> Matrix
plusM m1 m2
    | sameDimension m1 m2 = zipWith plusRow m1 m2
    | otherwise           = error "Matrices are not suitable!"

plusRow :: [Rational] -> [Rational] -> [Rational]
plusRow xs ys = zipWith (+) xs ys

-- 7.
isMultSuitable :: Matrix -> Matrix -> Bool
isMultSuitable m1 m2 = matrixWidth m1 == matrixHeight m2 &&
                      matrixHeight m1 == matrixWidth m2

timesM :: Matrix -> Matrix -> Matrix
timesM m1 m2
    | isMultSuitable m1 m2 = [ [dot col row | col <- transpose m2 ] | row <- m1]
    | otherwise            = error "Matrices are not suitable!"

dot :: [Rational] -> [Rational] -> Rational
dot xs ys = sum $ zipWith (*) xs ys

test_timesM =
    timesM [[1,2,3],[4,5,6]] [[7,8],[9,10],[11,12]] == [[58,64],[139,154]]

-- 8.
-- b.
zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' f xs ys = [f x y | (x,y) <- zip xs ys]

-- c.
zipWith'' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith'' f xs ys = map (uncurry f) $ zip xs ys

-- -----------------------------------
-- -----------------------------------
-- -- Optional material
-- -----------------------------------
-- -----------------------------------
-- -- 9.

-- Mapping functions
mapMatrix :: (a -> b) -> [[a]] -> [[b]]
mapMatrix f = map (map f)

zipMatrix :: (a -> b -> c) -> [[a]] -> [[b]] -> [[c]]
zipMatrix f = zipWith (zipWith f)

-- All ways of deleting a single element from a list
removes :: [a] -> [[a]]     
removes []     = []
removes (x:xs) = xs : map (x :) (removes xs)

-- Produce a matrix of minors from a given matrix
minors :: Matrix -> [[Matrix]]
minors m = map (map transpose . removes . transpose) (removes m)

-- A matrix where element a_ij = (-1)^(i + j)
signMatrix :: Int -> Int -> Matrix
signMatrix w h = cycleN h [evenRow, oddRow]
  where evenRow     = cycleN w [1,-1]
        oddRow      = cycleN w [-1,1]
        cycleN n xs = take n (cycle xs)
        
determinant :: Matrix -> Rational
determinant [[x]] = x
determinant m = sum (zipWith (*) row (cycle [1,-1]))
  where f x m = x * determinant m
        row   = head (zipMatrix f m (minors m))

cofactors :: Matrix -> Matrix
cofactors m = zipMatrix (*) (mapMatrix determinant (minors m)) signs
  where signs = signMatrix (matrixWidth m) (matrixHeight m)
        
                
scaleMatrix :: Rational -> Matrix -> Matrix
scaleMatrix k = mapMatrix (k *)

inverse :: Matrix -> Matrix
inverse m = scaleMatrix (1 / determinant m) (transpose (cofactors m))

-- Tests
identity :: Int -> Matrix
identity n = map f [0..n - 1]
  where f m = take n (replicate m 0 ++ [1] ++ repeat 0)

prop_inverse2 :: Rational -> Rational -> Rational 
                -> Rational -> Property
prop_inverse2 a b c d = determinant m /= 0 ==> 
                       m `timesM` inverse m    == identity 2
                       && inverse m `timesM` m == identity 2
  where m = [[a,b],[c,d]]
        
type Triple a = (a,a,a)
        
prop_inverse3 :: Triple Rational -> 
                 Triple Rational -> 
                 Triple Rational ->
                 Property
prop_inverse3 r1 r2 r3 = determinant m /= 0 ==> 
                         m `timesM` inverse m    == identity 3
                         && inverse m `timesM` m == identity 3
  where m           = [row r1, row r2, row r3]
        row (a,b,c) = [a,b,c] 