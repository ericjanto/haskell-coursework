import Test.QuickCheck
import Data.Char
import Control.Monad


-- Question 1

-- 1a

f :: String -> Bool
f = undefined

-- 1b

g :: String -> Bool
g = undefined

-- Question 2

-- 2a

p :: [(Int,Bool)] -> Bool
p = undefined
        
-- 2b

q :: [(Int,Bool)] -> Bool
q = undefined

-- 2c

r :: [(Int,Bool)] -> Bool
r = undefined

-- Question 3

type Nat = Int
data Term = Tm Nat Nat  deriving (Eq, Show)
data Poly = Pl [Term]   deriving (Eq, Show)
data Expr
  = X
  | C Nat
  | Expr :+: Expr
  | Expr :*: Expr
  | Expr :^: Expr
  deriving (Eq, Show)

nat :: Gen Int 
nat =  liftM abs arbitrary

instance Arbitrary Term where
  arbitrary = liftM2 Tm nat nat

instance Arbitrary Poly where
  arbitrary = liftM Pl arbitrary

showExpr :: Expr -> String
showExpr =  show

showTerm :: Term -> String
showTerm =  show

showPoly :: Poly -> String
showPoly =  show

expr0 :: Expr
expr0 = ((C 1 :*: (X :^: C 0)) :+:
        ((C 2 :*: (X :^: C 1)) :+:
        ((C 3 :*: (X :^: C 2)) :+:
        C 0)))

poly0 :: Poly
poly0 =  Pl [Tm 1 0, Tm 2 1, Tm 3 2]

-- 3a

evalExpr :: Expr -> Int -> Int
evalExpr = undefined
       
-- 3b

evalTerm :: Term -> Int -> Int
evalTerm = undefined

evalPoly :: Poly -> Int -> Int
evalPoly = undefined

-- 3c

exprTerm :: Term -> Expr
exprTerm = undefined

exprPoly :: Poly -> Expr
exprPoly = undefined