; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=gvn -S | FileCheck %s --check-prefixes=CHECK
; RUN: opt < %s -passes=gvn -disable-object-based-analysis -S | FileCheck %s --check-prefixes=CHECK-ENABLED

@a = external global i32		; <ptr> [#uses=7]

define i32 @test1() nounwind {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, ptr @a, align 4
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i32 [[TMP0]], 4
; CHECK-NEXT:    br i1 [[TMP1]], label [[BB:%.*]], label [[BB1:%.*]]
; CHECK:       bb:
; CHECK-NEXT:    br label [[BB8:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP0]], 5
; CHECK-NEXT:    br i1 [[TMP2]], label [[BB2:%.*]], label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       bb3:
; CHECK-NEXT:    br i1 false, label [[BB4:%.*]], label [[BB5:%.*]]
; CHECK:       bb4:
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, ptr @a, align 4
; CHECK-NEXT:    [[TMP4:%.*]] = add i32 [[TMP3]], 5
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       bb5:
; CHECK-NEXT:    br i1 false, label [[BB6:%.*]], label [[BB7:%.*]]
; CHECK:       bb6:
; CHECK-NEXT:    [[TMP5:%.*]] = load i32, ptr @a, align 4
; CHECK-NEXT:    [[TMP6:%.*]] = add i32 [[TMP5]], 4
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       bb7:
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       bb8:
; CHECK-NEXT:    [[DOT0:%.*]] = phi i32 [ [[TMP0]], [[BB7]] ], [ poison, [[BB6]] ], [ poison, [[BB4]] ], [ 4, [[BB2]] ], [ 5, [[BB]] ]
; CHECK-NEXT:    ret i32 [[DOT0]]
;
entry:
  %0 = load i32, ptr @a, align 4
  %1 = icmp eq i32 %0, 4
  br i1 %1, label %bb, label %bb1

bb:		; preds = %entry
  br label %bb8

bb1:		; preds = %entry
  %2 = load i32, ptr @a, align 4
  %3 = icmp eq i32 %2, 5
  br i1 %3, label %bb2, label %bb3

bb2:		; preds = %bb1
  br label %bb8

bb3:		; preds = %bb1
  %4 = load i32, ptr @a, align 4
  %5 = icmp eq i32 %4, 4
  br i1 %5, label %bb4, label %bb5

bb4:		; preds = %bb3
  %6 = load i32, ptr @a, align 4
  %7 = add i32 %6, 5
  br label %bb8

bb5:		; preds = %bb3
  %8 = load i32, ptr @a, align 4
  %9 = icmp eq i32 %8, 5
  br i1 %9, label %bb6, label %bb7

bb6:		; preds = %bb5
  %10 = load i32, ptr @a, align 4
  %11 = add i32 %10, 4
  br label %bb8

bb7:		; preds = %bb5
  %12 = load i32, ptr @a, align 4
  br label %bb8

bb8:		; preds = %bb7, %bb6, %bb4, %bb2, %bb
  %.0 = phi i32 [ %12, %bb7 ], [ %11, %bb6 ], [ %7, %bb4 ], [ 4, %bb2 ], [ 5, %bb ]
  br label %return

return:		; preds = %bb8
  ret i32 %.0
}

declare void @foo(i1)
declare void @bar(i32)

define void @test3(i32 %x, i32 %y) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[XZ:%.*]] = icmp eq i32 [[X:%.*]], 0
; CHECK-NEXT:    [[YZ:%.*]] = icmp eq i32 [[Y:%.*]], 0
; CHECK-NEXT:    [[Z:%.*]] = and i1 [[XZ]], [[YZ]]
; CHECK-NEXT:    br i1 [[Z]], label [[BOTH_ZERO:%.*]], label [[NOPE:%.*]]
; CHECK:       both_zero:
; CHECK-NEXT:    call void @foo(i1 true)
; CHECK-NEXT:    call void @foo(i1 true)
; CHECK-NEXT:    call void @bar(i32 0)
; CHECK-NEXT:    call void @bar(i32 0)
; CHECK-NEXT:    ret void
; CHECK:       nope:
; CHECK-NEXT:    call void @foo(i1 false)
; CHECK-NEXT:    ret void
;
  %xz = icmp eq i32 %x, 0
  %yz = icmp eq i32 %y, 0
  %z = and i1 %xz, %yz
  br i1 %z, label %both_zero, label %nope
both_zero:
  call void @foo(i1 %xz)
  call void @foo(i1 %yz)
  call void @bar(i32 %x)
  call void @bar(i32 %y)
  ret void
nope:
  call void @foo(i1 %z)
  ret void
}

define void @test3_select(i32 %x, i32 %y) {
; CHECK-LABEL: @test3_select(
; CHECK-NEXT:    [[XZ:%.*]] = icmp eq i32 [[X:%.*]], 0
; CHECK-NEXT:    [[YZ:%.*]] = icmp eq i32 [[Y:%.*]], 0
; CHECK-NEXT:    [[Z:%.*]] = select i1 [[XZ]], i1 [[YZ]], i1 false
; CHECK-NEXT:    br i1 [[Z]], label [[BOTH_ZERO:%.*]], label [[NOPE:%.*]]
; CHECK:       both_zero:
; CHECK-NEXT:    call void @foo(i1 true)
; CHECK-NEXT:    call void @foo(i1 true)
; CHECK-NEXT:    call void @bar(i32 0)
; CHECK-NEXT:    call void @bar(i32 0)
; CHECK-NEXT:    ret void
; CHECK:       nope:
; CHECK-NEXT:    call void @foo(i1 false)
; CHECK-NEXT:    ret void
;
  %xz = icmp eq i32 %x, 0
  %yz = icmp eq i32 %y, 0
  %z = select i1 %xz, i1 %yz, i1 false
  br i1 %z, label %both_zero, label %nope
both_zero:
  call void @foo(i1 %xz)
  call void @foo(i1 %yz)
  call void @bar(i32 %x)
  call void @bar(i32 %y)
  ret void
nope:
  call void @foo(i1 %z)
  ret void
}

define void @test3_or(i32 %x, i32 %y) {
; CHECK-LABEL: @test3_or(
; CHECK-NEXT:    [[XZ:%.*]] = icmp ne i32 [[X:%.*]], 0
; CHECK-NEXT:    [[YZ:%.*]] = icmp ne i32 [[Y:%.*]], 0
; CHECK-NEXT:    [[Z:%.*]] = or i1 [[XZ]], [[YZ]]
; CHECK-NEXT:    br i1 [[Z]], label [[NOPE:%.*]], label [[BOTH_ZERO:%.*]]
; CHECK:       both_zero:
; CHECK-NEXT:    call void @foo(i1 false)
; CHECK-NEXT:    call void @foo(i1 false)
; CHECK-NEXT:    call void @bar(i32 0)
; CHECK-NEXT:    call void @bar(i32 0)
; CHECK-NEXT:    ret void
; CHECK:       nope:
; CHECK-NEXT:    call void @foo(i1 true)
; CHECK-NEXT:    ret void
;
  %xz = icmp ne i32 %x, 0
  %yz = icmp ne i32 %y, 0
  %z = or i1 %xz, %yz
  br i1 %z, label %nope, label %both_zero
both_zero:
  call void @foo(i1 %xz)
  call void @foo(i1 %yz)
  call void @bar(i32 %x)
  call void @bar(i32 %y)
  ret void
nope:
  call void @foo(i1 %z)
  ret void
}

define void @test3_or_select(i32 %x, i32 %y) {
; CHECK-LABEL: @test3_or_select(
; CHECK-NEXT:    [[XZ:%.*]] = icmp ne i32 [[X:%.*]], 0
; CHECK-NEXT:    [[YZ:%.*]] = icmp ne i32 [[Y:%.*]], 0
; CHECK-NEXT:    [[Z:%.*]] = select i1 [[XZ]], i1 true, i1 [[YZ]]
; CHECK-NEXT:    br i1 [[Z]], label [[NOPE:%.*]], label [[BOTH_ZERO:%.*]]
; CHECK:       both_zero:
; CHECK-NEXT:    call void @foo(i1 false)
; CHECK-NEXT:    call void @foo(i1 false)
; CHECK-NEXT:    call void @bar(i32 0)
; CHECK-NEXT:    call void @bar(i32 0)
; CHECK-NEXT:    ret void
; CHECK:       nope:
; CHECK-NEXT:    call void @foo(i1 true)
; CHECK-NEXT:    ret void
;
  %xz = icmp ne i32 %x, 0
  %yz = icmp ne i32 %y, 0
  %z = select i1 %xz, i1 true, i1 %yz
  br i1 %z, label %nope, label %both_zero
both_zero:
  call void @foo(i1 %xz)
  call void @foo(i1 %yz)
  call void @bar(i32 %x)
  call void @bar(i32 %y)
  ret void
nope:
  call void @foo(i1 %z)
  ret void
}

define void @test4(i1 %b, i32 %x) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    br i1 [[B:%.*]], label [[SW:%.*]], label [[CASE3:%.*]]
; CHECK:       sw:
; CHECK-NEXT:    switch i32 [[X:%.*]], label [[DEFAULT:%.*]] [
; CHECK-NEXT:    i32 0, label [[CASE0:%.*]]
; CHECK-NEXT:    i32 1, label [[CASE1:%.*]]
; CHECK-NEXT:    i32 2, label [[CASE0]]
; CHECK-NEXT:    i32 3, label [[CASE3]]
; CHECK-NEXT:    i32 4, label [[DEFAULT]]
; CHECK-NEXT:    ]
; CHECK:       default:
; CHECK-NEXT:    call void @bar(i32 [[X]])
; CHECK-NEXT:    ret void
; CHECK:       case0:
; CHECK-NEXT:    call void @bar(i32 [[X]])
; CHECK-NEXT:    ret void
; CHECK:       case1:
; CHECK-NEXT:    call void @bar(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       case3:
; CHECK-NEXT:    call void @bar(i32 [[X]])
; CHECK-NEXT:    ret void
;
  br i1 %b, label %sw, label %case3
sw:
  switch i32 %x, label %default [
  i32 0, label %case0
  i32 1, label %case1
  i32 2, label %case0
  i32 3, label %case3
  i32 4, label %default
  ]
default:
  call void @bar(i32 %x)
  ret void
case0:
  call void @bar(i32 %x)
  ret void
case1:
  call void @bar(i32 %x)
  ret void
case3:
  call void @bar(i32 %x)
  ret void
}

define i1 @test5(i32 %x, i32 %y) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[SAME:%.*]], label [[DIFFERENT:%.*]]
; CHECK:       same:
; CHECK-NEXT:    ret i1 false
; CHECK:       different:
; CHECK-NEXT:    ret i1 false
;
  %cmp = icmp eq i32 %x, %y
  br i1 %cmp, label %same, label %different

same:
  %cmp2 = icmp ne i32 %x, %y
  ret i1 %cmp2

different:
  %cmp3 = icmp eq i32 %x, %y
  ret i1 %cmp3
}

define i1 @test6(i32 %x, i32 %y) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ne i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[X]], [[Y]]
; CHECK-NEXT:    br i1 [[CMP]], label [[SAME:%.*]], label [[DIFFERENT:%.*]]
; CHECK:       same:
; CHECK-NEXT:    ret i1 false
; CHECK:       different:
; CHECK-NEXT:    ret i1 false
;
  %cmp2 = icmp ne i32 %x, %y
  %cmp = icmp eq i32 %x, %y
  %cmp3 = icmp eq i32 %x, %y
  br i1 %cmp, label %same, label %different

same:
  ret i1 %cmp2

different:
  ret i1 %cmp3
}

define i1 @test6_fp(float %x, float %y) {
; CHECK-LABEL: @test6_fp(
; CHECK-NEXT:    [[CMP2:%.*]] = fcmp une float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = fcmp oeq float [[X]], [[Y]]
; CHECK-NEXT:    br i1 [[CMP]], label [[SAME:%.*]], label [[DIFFERENT:%.*]]
; CHECK:       same:
; CHECK-NEXT:    ret i1 false
; CHECK:       different:
; CHECK-NEXT:    ret i1 false
;
  %cmp2 = fcmp une float %x, %y
  %cmp = fcmp oeq float %x, %y
  %cmp3 = fcmp oeq float  %x, %y
  br i1 %cmp, label %same, label %different

same:
  ret i1 %cmp2

different:
  ret i1 %cmp3
}

define i1 @test7(i32 %x, i32 %y) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[SAME:%.*]], label [[DIFFERENT:%.*]]
; CHECK:       same:
; CHECK-NEXT:    ret i1 false
; CHECK:       different:
; CHECK-NEXT:    ret i1 false
;
  %cmp = icmp sgt i32 %x, %y
  br i1 %cmp, label %same, label %different

same:
  %cmp2 = icmp sle i32 %x, %y
  ret i1 %cmp2

different:
  %cmp3 = icmp sgt i32 %x, %y
  ret i1 %cmp3
}

define i1 @test7_fp(float %x, float %y) {
; CHECK-LABEL: @test7_fp(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[SAME:%.*]], label [[DIFFERENT:%.*]]
; CHECK:       same:
; CHECK-NEXT:    ret i1 false
; CHECK:       different:
; CHECK-NEXT:    ret i1 false
;
  %cmp = fcmp ogt float %x, %y
  br i1 %cmp, label %same, label %different

same:
  %cmp2 = fcmp ule float %x, %y
  ret i1 %cmp2

different:
  %cmp3 = fcmp ogt float %x, %y
  ret i1 %cmp3
}

define i1 @test8(i32 %x, i32 %y) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[CMP2:%.*]] = icmp sle i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[X]], [[Y]]
; CHECK-NEXT:    br i1 [[CMP]], label [[SAME:%.*]], label [[DIFFERENT:%.*]]
; CHECK:       same:
; CHECK-NEXT:    ret i1 false
; CHECK:       different:
; CHECK-NEXT:    ret i1 false
;
  %cmp2 = icmp sle i32 %x, %y
  %cmp = icmp sgt i32 %x, %y
  %cmp3 = icmp sgt i32 %x, %y
  br i1 %cmp, label %same, label %different

same:
  ret i1 %cmp2

different:
  ret i1 %cmp3
}

define i1 @test8_fp(float %x, float %y) {
; CHECK-LABEL: @test8_fp(
; CHECK-NEXT:    [[CMP2:%.*]] = fcmp ule float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ogt float [[X]], [[Y]]
; CHECK-NEXT:    br i1 [[CMP]], label [[SAME:%.*]], label [[DIFFERENT:%.*]]
; CHECK:       same:
; CHECK-NEXT:    ret i1 false
; CHECK:       different:
; CHECK-NEXT:    ret i1 false
;
  %cmp2 = fcmp ule float %x, %y
  %cmp = fcmp ogt float %x, %y
  %cmp3 = fcmp ogt float %x, %y
  br i1 %cmp, label %same, label %different

same:
  ret i1 %cmp2

different:
  ret i1 %cmp3
}

; PR1768
define i32 @test9(i32 %i, i32 %j) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[I:%.*]], [[J:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[COND_TRUE:%.*]], label [[RET:%.*]]
; CHECK:       cond_true:
; CHECK-NEXT:    ret i32 0
; CHECK:       ret:
; CHECK-NEXT:    ret i32 5
;
  %cmp = icmp eq i32 %i, %j
  br i1 %cmp, label %cond_true, label %ret

cond_true:
  %diff = sub i32 %i, %j
  ret i32 %diff

ret:
  ret i32 5
}

; PR1768
define i32 @test10(i32 %j, i32 %i) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[I:%.*]], [[J:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[COND_TRUE:%.*]], label [[RET:%.*]]
; CHECK:       cond_true:
; CHECK-NEXT:    ret i32 0
; CHECK:       ret:
; CHECK-NEXT:    ret i32 5
;
  %cmp = icmp eq i32 %i, %j
  br i1 %cmp, label %cond_true, label %ret

cond_true:
  %diff = sub i32 %i, %j
  ret i32 %diff

ret:
  ret i32 5
}

declare i32 @yogibar()

define i32 @test11(i32 %x) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[V0:%.*]] = call i32 @yogibar()
; CHECK-NEXT:    [[V1:%.*]] = call i32 @yogibar()
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[V0]], [[V1]]
; CHECK-NEXT:    br i1 [[CMP]], label [[COND_TRUE:%.*]], label [[NEXT:%.*]]
; CHECK:       cond_true:
; CHECK-NEXT:    ret i32 [[V0]]
; CHECK:       next:
; CHECK-NEXT:    [[CMP2:%.*]] = icmp eq i32 [[X:%.*]], [[V0]]
; CHECK-NEXT:    br i1 [[CMP2]], label [[COND_TRUE2:%.*]], label [[NEXT2:%.*]]
; CHECK:       cond_true2:
; CHECK-NEXT:    ret i32 [[X]]
; CHECK:       next2:
; CHECK-NEXT:    ret i32 0
;
  %v0 = call i32 @yogibar()
  %v1 = call i32 @yogibar()
  %cmp = icmp eq i32 %v0, %v1
  br i1 %cmp, label %cond_true, label %next

cond_true:
  ret i32 %v1

next:
  %cmp2 = icmp eq i32 %x, %v0
  br i1 %cmp2, label %cond_true2, label %next2

cond_true2:
  ret i32 %v0

next2:
  ret i32 0
}

define i32 @test12(i32 %x) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[X:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[COND_TRUE:%.*]], label [[COND_FALSE:%.*]]
; CHECK:       cond_true:
; CHECK-NEXT:    br label [[RET:%.*]]
; CHECK:       cond_false:
; CHECK-NEXT:    br label [[RET]]
; CHECK:       ret:
; CHECK-NEXT:    [[RES:%.*]] = phi i32 [ 0, [[COND_TRUE]] ], [ [[X]], [[COND_FALSE]] ]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %cmp = icmp eq i32 %x, 0
  br i1 %cmp, label %cond_true, label %cond_false

cond_true:
  br label %ret

cond_false:
  br label %ret

ret:
  %res = phi i32 [ %x, %cond_true ], [ %x, %cond_false ]
  ret i32 %res
}

; On the path from entry->if->end we know that ptr1==ptr2, so we can determine
; that gep2 does not alias ptr1 on that path (as it would require that
; ptr2==ptr2+2), so we can perform PRE of the load.
define i32 @test13(ptr %ptr1, ptr %ptr2) {
; CHECK-LABEL: @test13(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr i32, ptr [[PTR2:%.*]], i32 1
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr i32, ptr [[PTR2]], i32 2
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq ptr [[PTR1:%.*]], [[PTR2]]
; CHECK-NEXT:    br i1 [[CMP]], label [[IF:%.*]], label [[ENTRY_END_CRIT_EDGE:%.*]]
; CHECK:       entry.end_crit_edge:
; CHECK-NEXT:    [[VAL2_PRE:%.*]] = load i32, ptr [[GEP2]], align 4
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       if:
; CHECK-NEXT:    [[VAL1:%.*]] = load i32, ptr [[GEP2]], align 4
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[VAL2:%.*]] = phi i32 [ [[VAL1]], [[IF]] ], [ [[VAL2_PRE]], [[ENTRY_END_CRIT_EDGE]] ]
; CHECK-NEXT:    [[PHI1:%.*]] = phi ptr [ [[PTR2]], [[IF]] ], [ [[GEP1]], [[ENTRY_END_CRIT_EDGE]] ]
; CHECK-NEXT:    [[PHI2:%.*]] = phi i32 [ [[VAL1]], [[IF]] ], [ 0, [[ENTRY_END_CRIT_EDGE]] ]
; CHECK-NEXT:    store i32 0, ptr [[PHI1]], align 4
; CHECK-NEXT:    [[RET:%.*]] = add i32 [[PHI2]], [[VAL2]]
; CHECK-NEXT:    ret i32 [[RET]]
;
entry:
  %gep1 = getelementptr i32, ptr %ptr2, i32 1
  %gep2 = getelementptr i32, ptr %ptr2, i32 2
  %cmp = icmp eq ptr %ptr1, %ptr2
  br i1 %cmp, label %if, label %end


if:
  %val1 = load i32, ptr %gep2, align 4
  br label %end

end:
  %phi1 = phi ptr [ %ptr1, %if ], [ %gep1, %entry ]
  %phi2 = phi i32 [ %val1, %if ], [ 0, %entry ]
  store i32 0, ptr %phi1, align 4
  %val2 = load i32, ptr %gep2, align 4
  %ret = add i32 %phi2, %val2
  ret i32 %ret
}

define void @test14(ptr %ptr1, ptr noalias %ptr2) {
; CHECK-LABEL: @test14(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds i32, ptr [[PTR1:%.*]], i32 1
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr inbounds i32, ptr [[PTR1]], i32 2
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    br i1 undef, label [[LOOP_IF1_CRIT_EDGE:%.*]], label [[THEN:%.*]]
; CHECK:       loop.if1_crit_edge:
; CHECK-NEXT:    [[VAL2_PRE:%.*]] = load i32, ptr [[GEP2]], align 4
; CHECK-NEXT:    br label [[IF1:%.*]]
; CHECK:       if1:
; CHECK-NEXT:    [[VAL2:%.*]] = phi i32 [ [[VAL2_PRE]], [[LOOP_IF1_CRIT_EDGE]] ], [ [[VAL3:%.*]], [[LOOP_END:%.*]] ]
; CHECK-NEXT:    store i32 [[VAL2]], ptr [[GEP2]], align 4
; CHECK-NEXT:    store i32 0, ptr [[GEP1]], align 4
; CHECK-NEXT:    br label [[THEN]]
; CHECK:       then:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq ptr [[GEP2]], [[PTR2:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_END]], label [[IF2:%.*]]
; CHECK:       if2:
; CHECK-NEXT:    br label [[LOOP_END]]
; CHECK:       loop.end:
; CHECK-NEXT:    [[PHI3:%.*]] = phi ptr [ [[PTR2]], [[THEN]] ], [ [[PTR1]], [[IF2]] ]
; CHECK-NEXT:    [[VAL3]] = load i32, ptr [[GEP2]], align 4
; CHECK-NEXT:    store i32 [[VAL3]], ptr [[PHI3]], align 4
; CHECK-NEXT:    br i1 undef, label [[LOOP]], label [[IF1]]
;
; CHECK-ENABLED-LABEL: @test14(
; CHECK-ENABLED-NEXT:  entry:
; CHECK-ENABLED-NEXT:    [[GEP1:%.*]] = getelementptr inbounds i32, ptr [[PTR1:%.*]], i32 1
; CHECK-ENABLED-NEXT:    [[GEP2:%.*]] = getelementptr inbounds i32, ptr [[PTR1]], i32 2
; CHECK-ENABLED-NEXT:    br label [[LOOP:%.*]]
; CHECK-ENABLED:       loop:
; CHECK-ENABLED-NEXT:    br i1 undef, label [[LOOP_IF1_CRIT_EDGE:%.*]], label [[THEN:%.*]]
; CHECK-ENABLED:       if1:
; CHECK-ENABLED-NEXT:    [[VAL2:%.*]] = load i32, ptr [[GEP2]], align 4
; CHECK-ENABLED-NEXT:    store i32 [[VAL2]], ptr [[GEP2]], align 4
; CHECK-ENABLED-NEXT:    store i32 0, ptr [[GEP1]], align 4
; CHECK-ENABLED-NEXT:    br label [[THEN]]
; CHECK-ENABLED:       then:
; CHECK-ENABLED-NEXT:    [[CMP:%.*]] = icmp eq ptr [[GEP2]], [[PTR2:%.*]]
; CHECK-ENABLED-NEXT:    br i1 [[CMP]], label [[LOOP_END:%.*]], label [[IF2:%.*]]
; CHECK-ENABLED:       if2:
; CHECK-ENABLED-NEXT:    br label [[LOOP_END]]
; CHECK-ENABLED:       loop.end:
; CHECK-ENABLED-NEXT:    [[PHI3:%.*]] = phi ptr [ [[PTR2]], [[THEN]] ], [ [[PTR1]], [[IF2]] ]
; CHECK-ENABLED-NEXT:    [[VAL3:%.*]] = load i32, ptr [[GEP2]], align 4
; CHECK-ENABLED-NEXT:    store i32 [[VAL3]], ptr [[PHI3]], align 4
; CHECK-ENABLED-NEXT:    br i1 undef, label [[LOOP]], label [[IF1:%.*]]
entry:
  %gep1 = getelementptr inbounds i32, ptr %ptr1, i32 1
  %gep2 = getelementptr inbounds i32, ptr %ptr1, i32 2
  br label %loop

loop:
  %phi1 = phi ptr [ %gep3, %loop.end ], [ %gep1, %entry ]
  br i1 undef, label %if1, label %then


if1:
  %val2 = load i32, ptr %gep2, align 4
  store i32 %val2, ptr %gep2, align 4
  store i32 0, ptr %phi1, align 4
  br label %then

then:
  %cmp = icmp eq ptr %gep2, %ptr2
  br i1 %cmp, label %loop.end, label %if2

if2:
  br label %loop.end

loop.end:
  %phi3 = phi ptr [ %gep2, %then ], [ %ptr1, %if2 ]
  %val3 = load i32, ptr %gep2, align 4
  store i32 %val3, ptr %phi3, align 4
  %gep3 = getelementptr inbounds i32, ptr %ptr1, i32 1
  br i1 undef, label %loop, label %if1
}
