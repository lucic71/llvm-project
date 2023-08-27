// RUN: %clang_cc1 -fdrop-inbounds-from-gep -triple x86_64-unknown-linux-gnu  -emit-llvm < %s | FileCheck %s

typedef
struct S1 {
    char c;
    int x;
} S1;

S1 s1;
void test20(void) {
    // CHECK-LABEL: test20
    // CHECK: {{%.*}} = load i32, ptr getelementptr inbounds (%struct.S1, ptr @s1, i32 0, i32 1)
    // CHECK: store i32 {{%.*}}, ptr getelementptr inbounds (%struct.S1, ptr @s1, i32 0, i32 1)
    s1.x++;
}

void test21(void) {
  // CHECK-LABEL: test21
  // CHECK: {{%.*}} = alloca %struct.S1
  // CHECK: {{%.*}} = getelementptr %struct.S1, ptr {{%.*}}, i32 0, i32 1
  S1 s1_2;
  s1_2.x++;
}
