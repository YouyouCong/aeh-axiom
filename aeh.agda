module AEH where

-- Source

data VTy : Set
data CTy : Set
data HTy : Set
data Eff : Set
    
data VTy where
  b   : VTy
  _⇒_ : VTy → CTy → VTy

data CTy where
  _!_ : VTy → Eff → CTy

infix 4 _!_

data HTy where
  _⇒_ : CTy → CTy → HTy

data Eff where
  -- ι   : Eff
  _⇀_ : VTy → VTy → Eff

infixr 5 _⇀_

variable
  A B Aₒ Bₒ : VTy
  C D : CTy
  E   : Eff

data Val (v : VTy → Set) : VTy → Set
data Cmp (v : VTy → Set) : CTy → Set
data Hdl (v : VTy → Set) : HTy → Set

data Val v where
  var : v A → Val v A
  abs : (v A → Cmp v C) → Val v (A ⇒ C)

data Cmp v where
  ret : Val v A → Cmp v (A ! E)
  app : Val v (A ⇒ C) → Val v A → Cmp v C
  val : Cmp v (A ! E) → (v A → Cmp v (B ! E)) → Cmp v (B ! E)
  op  : Val v A → Cmp v (B ! A ⇀ B)
  handle : Cmp v C → Hdl v (C ⇒ D) → Cmp v D

data Hdl v where
  hdl : (v A → Cmp v C) → (v Aₒ → v (Bₒ ⇒ C) → Cmp v C) → 
        Hdl v ((A ! Aₒ ⇀ Bₒ) ⇒ C)

-- Target

data Ty : Set where
  b   : Ty
  _⇒_ : Ty → Ty → Ty

infixr 5 _⇒_

variable
  α β αᵢ αₒ ω : Ty

TCntTy : Ty → Ty → Ty → Ty → Ty
TCntTy α αᵢ αₒ ω = α ⇒ (αᵢ ⇒ (αₒ ⇒ ω) ⇒ ω) ⇒ ω

THdlTy : Ty → Ty → Ty → Ty → Ty
THdlTy α αᵢ αₒ ω = αᵢ ⇒ (αₒ ⇒ ω) ⇒ ω

TRootTy : Ty → Ty → Ty → Ty → Ty
TRootTy α αᵢ αₒ ω = TCntTy α αᵢ αₒ ω ⇒ THdlTy α αᵢ αₒ ω ⇒ ω

data TRoot (v : Ty → Set) : Ty → Set
data TTerm (v : Ty → Set) : Ty → Set
data TVal  (v : Ty → Set) : Ty → Set
data TCnt  (v : Ty → Set) : Ty → Set
data THdl  (v : Ty → Set) : Ty → Set

data TRoot v where
  root : v (α ⇒ (αᵢ ⇒ (αₒ ⇒ ω) ⇒ ω) ⇒ ω) → 
         v (αᵢ ⇒ (αₒ ⇒ ω) ⇒ ω) →
         TRoot v (TRootTy α αᵢ αₒ ω)

data TTerm v where
  app : TVal v (α ⇒ TRootTy β αᵢ αₒ ω) →
        TVal v α →
        TTerm v (TRootTy β αᵢ αₒ ω)
  run : TRoot v (TRootTy α αᵢ αₒ ω) →
        TCnt v (TCntTy α αᵢ αₒ ω) →
        THdl v (THdlTy α αᵢ αₒ ω) →
        TTerm v ω
  ret : TCnt v (TCntTy α αᵢ αₒ ω) →
        TVal v α →
        THdl v (THdlTy α αᵢ αₒ ω) →
        TTerm v ω
  op  : THdl v (THdlTy α αᵢ αₒ ω) →
        TVal v α →
        TCnt v (TCntTy α αᵢ αₒ ω) →
        TTerm v ω

data TVal v where
  var : v α → TVal v α
  abs : (v α → TRoot v (TRootTy β αᵢ αₒ ω)) → 
        TVal v (α ⇒ (TRootTy β αᵢ αₒ ω))

data TCnt v where
  cnt : v α → v (αᵢ ⇒ (αₒ ⇒ ω) ⇒ ω) → 
        TCnt v (α ⇒ αᵢ ⇒ (αₒ ⇒ ω) ⇒ ω)

data THdl v where
  hdl : v αᵢ → v (αₒ ⇒ ω) → 
        THdl v (αᵢ ⇒ (αₒ ⇒ ω) ⇒ ω)