From Hammer Require Import Hammer.









Require Export SetoidList Morphisms OrdersTac.
Set Implicit Arguments.
Unset Strict Implicit.





Inductive Compare (X : Type) (lt eq : X -> X -> Prop) (x y : X) : Type :=
| LT : lt x y -> Compare lt eq x y
| EQ : eq x y -> Compare lt eq x y
| GT : lt y x -> Compare lt eq x y.

Arguments LT [X lt eq x y] _.
Arguments EQ [X lt eq x y] _.
Arguments GT [X lt eq x y] _.

Module Type MiniOrderedType.

Parameter Inline t : Type.

Parameter Inline eq : t -> t -> Prop.
Parameter Inline lt : t -> t -> Prop.

Axiom eq_refl : forall x : t, eq x x.
Axiom eq_sym : forall x y : t, eq x y -> eq y x.
Axiom eq_trans : forall x y z : t, eq x y -> eq y z -> eq x z.

Axiom lt_trans : forall x y z : t, lt x y -> lt y z -> lt x z.
Axiom lt_not_eq : forall x y : t, lt x y -> ~ eq x y.

Parameter compare : forall x y : t, Compare lt eq x y.

Hint Immediate eq_sym.
Hint Resolve eq_refl eq_trans lt_not_eq lt_trans.

End MiniOrderedType.

Module Type OrderedType.
Include MiniOrderedType.


Parameter eq_dec : forall x y, { eq x y } + { ~ eq x y }.

End OrderedType.

Module MOT_to_OT (Import O : MiniOrderedType) <: OrderedType.
Include O.

Definition eq_dec : forall x y : t, {eq x y} + {~ eq x y}.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedType.eq_dec". Undo.  
intros; elim (compare x y); intro H; [ right | left | right ]; auto.
assert (~ eq y x); auto.
Defined.

End MOT_to_OT.





Module OrderedTypeFacts (Import O: OrderedType).

Instance eq_equiv : Equivalence eq.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.eq_equiv". Undo.   split; [ exact eq_refl | exact eq_sym | exact eq_trans ]. Qed.

Lemma lt_antirefl : forall x, ~ lt x x.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.lt_antirefl". Undo.  
intros; intro; absurd (eq x x); auto.
Qed.

Instance lt_strorder : StrictOrder lt.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.lt_strorder". Undo.   split; [ exact lt_antirefl | exact lt_trans]. Qed.

Lemma lt_eq : forall x y z, lt x y -> eq y z -> lt x z.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.lt_eq". Undo.  
intros; destruct (compare x z) as [Hlt|Heq|Hlt]; auto.
elim (lt_not_eq H); apply eq_trans with z; auto.
elim (lt_not_eq (lt_trans Hlt H)); auto.
Qed.

Lemma eq_lt : forall x y z, eq x y -> lt y z -> lt x z.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.eq_lt". Undo.  
intros; destruct (compare x z) as [Hlt|Heq|Hlt]; auto.
elim (lt_not_eq H0); apply eq_trans with x; auto.
elim (lt_not_eq (lt_trans H0 Hlt)); auto.
Qed.

Instance lt_compat : Proper (eq==>eq==>iff) lt.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.lt_compat". Undo.  
apply proper_sym_impl_iff_2; auto with *.
intros x x' Hx y y' Hy H.
apply eq_lt with x; auto.
apply lt_eq with y; auto.
Qed.

Lemma lt_total : forall x y, lt x y \/ eq x y \/ lt y x.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.lt_total". Undo.   intros; destruct (compare x y); auto. Qed.

Module TO.
Definition t := t.
Definition eq := eq.
Definition lt := lt.
Definition le x y := lt x y \/ eq x y.
End TO.
Module IsTO.
Definition eq_equiv := eq_equiv.
Definition lt_strorder := lt_strorder.
Definition lt_compat := lt_compat.
Definition lt_total := lt_total.
Lemma le_lteq x y : TO.le x y <-> lt x y \/ eq x y.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.IsTO.le_lteq". Undo.   reflexivity. Qed.
End IsTO.
Module OrderTac := !MakeOrderTac TO IsTO.
Ltac order := OrderTac.order.

Lemma le_eq x y z : ~lt x y -> eq y z -> ~lt x z. Proof. order. Qed.
Lemma eq_le x y z : eq x y -> ~lt y z -> ~lt x z. Proof. order. Qed.
Lemma neq_eq x y z : ~eq x y -> eq y z -> ~eq x z. Proof. order. Qed.
Lemma eq_neq x y z : eq x y -> ~eq y z -> ~eq x z. Proof. order. Qed.
Lemma le_lt_trans x y z : ~lt y x -> lt y z -> lt x z. Proof. order. Qed.
Lemma lt_le_trans x y z : lt x y -> ~lt z y -> lt x z. Proof. order. Qed.
Lemma le_neq x y : ~lt x y -> ~eq x y -> lt y x. Proof. order. Qed.
Lemma le_trans x y z : ~lt y x -> ~lt z y -> ~lt z x. Proof. order. Qed.
Lemma le_antisym x y : ~lt y x -> ~lt x y -> eq x y. Proof. order. Qed.
Lemma neq_sym x y : ~eq x y -> ~eq y x. Proof. order. Qed.
Lemma lt_le x y : lt x y -> ~lt y x. Proof. order. Qed.
Lemma gt_not_eq x y : lt y x -> ~ eq x y. Proof. order. Qed.
Lemma eq_not_lt x y : eq x y -> ~ lt x y. Proof. order. Qed.
Lemma eq_not_gt x y : eq x y -> ~ lt y x. Proof. order. Qed.
Lemma lt_not_gt x y : lt x y -> ~ lt y x. Proof. order. Qed.

Hint Resolve gt_not_eq eq_not_lt.
Hint Immediate eq_lt lt_eq le_eq eq_le neq_eq eq_neq.
Hint Resolve eq_not_gt lt_antirefl lt_not_gt.

Lemma elim_compare_eq :
forall x y : t,
eq x y -> exists H : eq x y, compare x y = EQ H.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.elim_compare_eq". Undo.  
intros; case (compare x y); intros H'; try (exfalso; order).
exists H'; auto.
Qed.

Lemma elim_compare_lt :
forall x y : t,
lt x y -> exists H : lt x y, compare x y = LT H.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.elim_compare_lt". Undo.  
intros; case (compare x y); intros H'; try (exfalso; order).
exists H'; auto.
Qed.

Lemma elim_compare_gt :
forall x y : t,
lt y x -> exists H : lt y x, compare x y = GT H.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.elim_compare_gt". Undo.  
intros; case (compare x y); intros H'; try (exfalso; order).
exists H'; auto.
Qed.

Ltac elim_comp :=
match goal with
| |- ?e => match e with
| context ctx [ compare ?a ?b ] =>
let H := fresh in
(destruct (compare a b) as [H|H|H]; try order)
end
end.

Ltac elim_comp_eq x y :=
elim (elim_compare_eq (x:=x) (y:=y));
[ intros _1 _2; rewrite _2; clear _1 _2 | auto ].

Ltac elim_comp_lt x y :=
elim (elim_compare_lt (x:=x) (y:=y));
[ intros _1 _2; rewrite _2; clear _1 _2 | auto ].

Ltac elim_comp_gt x y :=
elim (elim_compare_gt (x:=x) (y:=y));
[ intros _1 _2; rewrite _2; clear _1 _2 | auto ].


Definition eq_dec := eq_dec.

Lemma lt_dec : forall x y : t, {lt x y} + {~ lt x y}.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.lt_dec". Undo.  
intros; elim (compare x y); [ left | right | right ]; auto.
Defined.

Definition eqb x y : bool := if eq_dec x y then true else false.

Lemma eqb_alt :
forall x y, eqb x y = match compare x y with EQ _ => true | _ => false end.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.eqb_alt". Undo.  
unfold eqb; intros; destruct (eq_dec x y); elim_comp; auto.
Qed.



Section ForNotations.

Notation In:=(InA eq).
Notation Inf:=(lelistA lt).
Notation Sort:=(sort lt).
Notation NoDup:=(NoDupA eq).

Lemma In_eq : forall l x y, eq x y -> In x l -> In y l.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.In_eq". Undo.   exact (InA_eqA eq_equiv). Qed.

Lemma ListIn_In : forall l x, List.In x l -> In x l.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.ListIn_In". Undo.   exact (In_InA eq_equiv). Qed.

Lemma Inf_lt : forall l x y, lt x y -> Inf y l -> Inf x l.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.Inf_lt". Undo.   exact (InfA_ltA lt_strorder). Qed.

Lemma Inf_eq : forall l x y, eq x y -> Inf y l -> Inf x l.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.Inf_eq". Undo.   exact (InfA_eqA eq_equiv lt_compat). Qed.

Lemma Sort_Inf_In : forall l x a, Sort l -> Inf a l -> In x l -> lt a x.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.Sort_Inf_In". Undo.   exact (SortA_InfA_InA eq_equiv lt_strorder lt_compat). Qed.

Lemma ListIn_Inf : forall l x, (forall y, List.In y l -> lt x y) -> Inf x l.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.ListIn_Inf". Undo.   exact (@In_InfA t lt). Qed.

Lemma In_Inf : forall l x, (forall y, In y l -> lt x y) -> Inf x l.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.In_Inf". Undo.   exact (InA_InfA eq_equiv (ltA:=lt)). Qed.

Lemma Inf_alt :
forall l x, Sort l -> (Inf x l <-> (forall y, In y l -> lt x y)).
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.Inf_alt". Undo.   exact (InfA_alt eq_equiv lt_strorder lt_compat). Qed.

Lemma Sort_NoDup : forall l, Sort l -> NoDup l.
Proof. try hammer_hook "OrderedType" "OrderedType.OrderedTypeFacts.Sort_NoDup". Undo.   exact (SortA_NoDupA eq_equiv lt_strorder lt_compat). Qed.

End ForNotations.

Hint Resolve ListIn_In Sort_NoDup Inf_lt.
Hint Immediate In_eq Inf_lt.

End OrderedTypeFacts.

Module KeyOrderedType(O:OrderedType).
Import O.
Module MO:=OrderedTypeFacts(O).
Import MO.

Section Elt.
Variable elt : Type.
Notation key:=t.

Definition eqk (p p':key*elt) := eq (fst p) (fst p').
Definition eqke (p p':key*elt) :=
eq (fst p) (fst p') /\ (snd p) = (snd p').
Definition ltk (p p':key*elt) := lt (fst p) (fst p').

Hint Unfold eqk eqke ltk.
Hint Extern 2 (eqke ?a ?b) => split.



Lemma eqke_eqk : forall x x', eqke x x' -> eqk x x'.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqke_eqk". Undo.  
unfold eqk, eqke; intuition.
Qed.



Lemma ltk_right_r : forall x k e e', ltk x (k,e) -> ltk x (k,e').
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_right_r". Undo.   auto. Qed.

Lemma ltk_right_l : forall x k e e', ltk (k,e) x -> ltk (k,e') x.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_right_l". Undo.   auto. Qed.
Hint Immediate ltk_right_r ltk_right_l.



Lemma eqk_refl : forall e, eqk e e.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqk_refl". Undo.   auto. Qed.

Lemma eqke_refl : forall e, eqke e e.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqke_refl". Undo.   auto. Qed.

Lemma eqk_sym : forall e e', eqk e e' -> eqk e' e.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqk_sym". Undo.   auto. Qed.

Lemma eqke_sym : forall e e', eqke e e' -> eqke e' e.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqke_sym". Undo.   unfold eqke; intuition. Qed.

Lemma eqk_trans : forall e e' e'', eqk e e' -> eqk e' e'' -> eqk e e''.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqk_trans". Undo.   eauto. Qed.

Lemma eqke_trans : forall e e' e'', eqke e e' -> eqke e' e'' -> eqke e e''.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqke_trans". Undo.  
unfold eqke; intuition; [ eauto | congruence ].
Qed.

Lemma ltk_trans : forall e e' e'', ltk e e' -> ltk e' e'' -> ltk e e''.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_trans". Undo.   eauto. Qed.

Lemma ltk_not_eqk : forall e e', ltk e e' -> ~ eqk e e'.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_not_eqk". Undo.   unfold eqk, ltk; auto. Qed.

Lemma ltk_not_eqke : forall e e', ltk e e' -> ~eqke e e'.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_not_eqke". Undo.  
unfold eqke, ltk; intuition; simpl in *; subst.
exact (lt_not_eq H H1).
Qed.

Hint Resolve eqk_trans eqke_trans eqk_refl eqke_refl.
Hint Resolve ltk_trans ltk_not_eqk ltk_not_eqke.
Hint Immediate eqk_sym eqke_sym.

Global Instance eqk_equiv : Equivalence eqk.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqk_equiv". Undo.   constructor; eauto. Qed.

Global Instance eqke_equiv : Equivalence eqke.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqke_equiv". Undo.   split; eauto. Qed.

Global Instance ltk_strorder : StrictOrder ltk.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_strorder". Undo.   constructor; eauto. intros x; apply (irreflexivity (x:=fst x)). Qed.

Global Instance ltk_compat : Proper (eqk==>eqk==>iff) ltk.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_compat". Undo.  
intros (x,e) (x',e') Hxx' (y,f) (y',f') Hyy'; compute.
compute in Hxx'; compute in Hyy'. rewrite Hxx', Hyy'; auto.
Qed.

Global Instance ltk_compat' : Proper (eqke==>eqke==>iff) ltk.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_compat'". Undo.  
intros (x,e) (x',e') (Hxx',_) (y,f) (y',f') (Hyy',_); compute.
compute in Hxx'; compute in Hyy'. rewrite Hxx', Hyy'; auto.
Qed.



Lemma eqk_not_ltk : forall x x', eqk x x' -> ~ltk x x'.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqk_not_ltk". Undo.  
unfold eqk, ltk; simpl; auto.
Qed.

Lemma ltk_eqk : forall e e' e'', ltk e e' -> eqk e' e'' -> ltk e e''.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.ltk_eqk". Undo.   eauto. Qed.

Lemma eqk_ltk : forall e e' e'', eqk e e' -> ltk e' e'' -> ltk e e''.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.eqk_ltk". Undo.  
intros (k,e) (k',e') (k'',e'').
unfold ltk, eqk; simpl; eauto.
Qed.
Hint Resolve eqk_not_ltk.
Hint Immediate ltk_eqk eqk_ltk.

Lemma InA_eqke_eqk :
forall x m, InA eqke x m -> InA eqk x m.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.InA_eqke_eqk". Undo.  
unfold eqke; induction 1; intuition.
Qed.
Hint Resolve InA_eqke_eqk.

Definition MapsTo (k:key)(e:elt):= InA eqke (k,e).
Definition In k m := exists e:elt, MapsTo k e m.
Notation Sort := (sort ltk).
Notation Inf := (lelistA ltk).

Hint Unfold MapsTo In.



Lemma In_alt : forall k l, In k l <-> exists e, InA eqk (k,e) l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.In_alt". Undo.  
firstorder.
exists x; auto.
induction H.
destruct y.
exists e; auto.
destruct IHInA as [e H0].
exists e; auto.
Qed.

Lemma MapsTo_eq : forall l x y e, eq x y -> MapsTo x e l -> MapsTo y e l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.MapsTo_eq". Undo.  
intros; unfold MapsTo in *; apply InA_eqA with (x,e); eauto with *.
Qed.

Lemma In_eq : forall l x y, eq x y -> In x l -> In y l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.In_eq". Undo.  
destruct 2 as (e,E); exists e; eapply MapsTo_eq; eauto.
Qed.

Lemma Inf_eq : forall l x x', eqk x x' -> Inf x' l -> Inf x l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.Inf_eq". Undo.   exact (InfA_eqA eqk_equiv ltk_compat). Qed.

Lemma Inf_lt : forall l x x', ltk x x' -> Inf x' l -> Inf x l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.Inf_lt". Undo.   exact (InfA_ltA ltk_strorder). Qed.

Hint Immediate Inf_eq.
Hint Resolve Inf_lt.

Lemma Sort_Inf_In :
forall l p q, Sort l -> Inf q l -> InA eqk p l -> ltk q p.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.Sort_Inf_In". Undo.  
exact (SortA_InfA_InA eqk_equiv ltk_strorder ltk_compat).
Qed.

Lemma Sort_Inf_NotIn :
forall l k e, Sort l -> Inf (k,e) l ->  ~In k l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.Sort_Inf_NotIn". Undo.  
intros; red; intros.
destruct H1 as [e' H2].
elim (@ltk_not_eqk (k,e) (k,e')).
eapply Sort_Inf_In; eauto.
red; simpl; auto.
Qed.

Lemma Sort_NoDupA: forall l, Sort l -> NoDupA eqk l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.Sort_NoDupA". Undo.  
exact (SortA_NoDupA eqk_equiv ltk_strorder ltk_compat).
Qed.

Lemma Sort_In_cons_1 : forall e l e', Sort (e::l) -> InA eqk e' l -> ltk e e'.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.Sort_In_cons_1". Undo.  
inversion 1; intros; eapply Sort_Inf_In; eauto.
Qed.

Lemma Sort_In_cons_2 : forall l e e', Sort (e::l) -> InA eqk e' (e::l) ->
ltk e e' \/ eqk e e'.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.Sort_In_cons_2". Undo.  
inversion_clear 2; auto.
left; apply Sort_In_cons_1 with l; auto.
Qed.

Lemma Sort_In_cons_3 :
forall x l k e, Sort ((k,e)::l) -> In x l -> ~eq x k.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.Sort_In_cons_3". Undo.  
inversion_clear 1; red; intros.
destruct (Sort_Inf_NotIn H0 H1 (In_eq H2 H)).
Qed.

Lemma In_inv : forall k k' e l, In k ((k',e) :: l) -> eq k k' \/ In k l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.In_inv". Undo.  
inversion 1.
inversion_clear H0; eauto.
destruct H1; simpl in *; intuition.
Qed.

Lemma In_inv_2 : forall k k' e e' l,
InA eqk (k, e) ((k', e') :: l) -> ~ eq k k' -> InA eqk (k, e) l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.In_inv_2". Undo.  
inversion_clear 1; compute in H0; intuition.
Qed.

Lemma In_inv_3 : forall x x' l,
InA eqke x (x' :: l) -> ~ eqk x x' -> InA eqke x l.
Proof. try hammer_hook "OrderedType" "OrderedType.KeyOrderedType.In_inv_3". Undo.  
inversion_clear 1; compute in H0; intuition.
Qed.

End Elt.

Hint Unfold eqk eqke ltk.
Hint Extern 2 (eqke ?a ?b) => split.
Hint Resolve eqk_trans eqke_trans eqk_refl eqke_refl.
Hint Resolve ltk_trans ltk_not_eqk ltk_not_eqke.
Hint Immediate eqk_sym eqke_sym.
Hint Resolve eqk_not_ltk.
Hint Immediate ltk_eqk eqk_ltk.
Hint Resolve InA_eqke_eqk.
Hint Unfold MapsTo In.
Hint Immediate Inf_eq.
Hint Resolve Inf_lt.
Hint Resolve Sort_Inf_NotIn.
Hint Resolve In_inv_2 In_inv_3.

End KeyOrderedType.


