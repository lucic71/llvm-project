// RUN: clang -O2 -S -emit-llvm -o - %s | FileCheck %s --check-prefixes=CHECK
// RUN: clang -O2 -S -emit-llvm -mllvm -trap-on-oob -mllvm -disable-oob-analysis -o - %s | FileCheck %s --check-prefixes=CHECK-ENABLED

extern void *memcpy(void *dest, const void *src, unsigned long n);
extern void *memset(void *s, int c, unsigned long n);

int foo1() {
// CHECK: ret i32 poison

// CHECK-ENABLED: tail call void @llvm.trap()  
// CHECK-ENABLED-NEXT: unreachable  

        int arr[2];
        arr[3] = 4;
	return arr[3];
}

int foo2(int c) {
// CHECK: [[IDXPROM:%.*]] = sext i32 [[C:%.*]] to i64
// CHECK-NEXT: [[ARRAYIDX:%.*]] = getelementptr inbounds [5 x i32], ptr [[SRC:@.*]], i64 0, i64 [[IDXPROM]]
// CHECK-NEXT: [[RET:%.*]] = load i32, ptr [[ARRAYIDX]]
// CHECK-NEXT: ret i32 [[RET]]

// CHECK-ENABLED: [[IDXPROM:%.*]] = sext i32 [[C:%.*]] to i64
// CHECK-ENABLED-NEXT: [[ARRAYIDX:%.*]] = getelementptr inbounds [5 x i32], ptr [[SRC:@.*]], i64 0, i64 [[IDXPROM]]
// CHECK-ENABLED-NEXT: [[RET:%.*]] = load i32, ptr [[ARRAYIDX]]
// CHECK-ENABLED-NEXT: ret i32 [[RET]]

        int src[5] = {1,2,3,4,5}, dst[5];
        memcpy(dst, src, 6 * sizeof(int));
        return dst[c];
}

int foo3(int c) {
// CHECK: ret i32 undef

// CHECK-ENABLED: [[DST:%.*]] = alloca [2 x i32]
// CHECK-ENABLED-NEXT: call void @llvm.lifetime.start.p0(i64 8, ptr nonnull [[DST]])
// CHECK-ENABLED-NEXT: call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(12) [[DST]], i8 0, i64 12, i1 false)
// CHECK-ENABLED-NEXT: [[IDXPROM:%.*]] = sext i32 [[C:%.*]] to i64
// CHECK-ENABLED-NEXT: [[ARRAYIDX:%.*]] = getelementptr inbounds [2 x i32], ptr [[DST]], i64 0, i64 [[IDXPROM]]
// CHECK-ENABLED-NEXT: [[RET:%.*]] = load i32, ptr [[ARRAYIDX]]
// CHECK-ENABLED-NEXT: call void @llvm.lifetime.end.p0(i64 8, ptr nonnull [[DST]])
// CHECK-ENABLED-NEXT: ret i32 [[RET]]

        int dst[2];
        memset(dst, 0, 3 * sizeof(int));
        return dst[c];
}

int foo4(int c) {
// CHECK-ENABLED: [[DST:%.*]] = alloca [2 x i32]
// CHECK-ENABLED-NEXT: call void @llvm.lifetime.start.p0(i64 8, ptr nonnull [[DST]])
// CHECK-ENABLED-NEXT: store i32 0, ptr [[DST]]
// CHECK-ENABLED-NEXT: [[ARRAYIDX1:%.*]] = getelementptr inbounds [2 x i32], ptr [[DST]], i64 0, i64 1
// CHECK-ENABLED-NEXT: store i32 1, ptr [[ARRAYIDX1]]
// CHECK-ENABLED-NEXT: [[ARRAYIDX2:%.*]] = getelementptr inbounds [2 x i32], ptr [[DST]], i64 0, i64 2
// CHECK-ENABLED-NEXT: store i32 2, ptr [[ARRAYIDX2]]
// CHECK-ENABLED-NEXT: [[IDXPROM:%.*]] = sext i32 [[C:%.*]] to i64
// CHECK-ENABLED-NEXT: [[ARRAYIDX:%.*]] = getelementptr inbounds [2 x i32], ptr [[DST]], i64 0, i64 [[IDXPROM]]
// CHECK-ENABLED-NEXT: [[RET:%.*]] = load i32, ptr [[ARRAYIDX]]
// CHECK-ENABLED-NEXT: call void @llvm.lifetime.end.p0(i64 8, ptr nonnull [[DST]])
// CHECK-ENABLED-NEXT: ret i32 [[RET]]

// CHECK: [[DST:%.*]] = alloca [2 x i32]
// CHECK-NEXT: call void @llvm.lifetime.start.p0(i64 8, ptr nonnull [[DST]])
// CHECK-NEXT: store i32 0, ptr [[DST]]
// CHECK-NEXT: [[ARRAYIDX1:%.*]] = getelementptr inbounds [2 x i32], ptr [[DST]], i64 0, i64 1
// CHECK-NEXT: store i32 1, ptr [[ARRAYIDX1]]
// CHECK-NEXT: [[ARRAYIDX2:%.*]] = getelementptr inbounds [2 x i32], ptr [[DST]], i64 0, i64 2
// CHECK-NEXT: store i32 2, ptr [[ARRAYIDX2]]
// CHECK-NEXT: [[IDXPROM:%.*]] = sext i32 [[C:%.*]] to i64
// CHECK-NEXT: [[ARRAYIDX:%.*]] = getelementptr inbounds [2 x i32], ptr [[DST]], i64 0, i64 [[IDXPROM]]
// CHECK-NEXT: [[RET:%.*]] = load i32, ptr [[ARRAYIDX]]
// CHECK-NEXT: call void @llvm.lifetime.end.p0(i64 8, ptr nonnull [[DST]])
// CHECK-NEXT: ret i32 [[RET]]


        int dst[2];
        for (int i = 0; i < 3; ++i) {
                dst[i] = i;
        }
        return dst[c];
}
