;=========================== begin_copyright_notice ============================
;
; Copyright (C) 2022-2024 Intel Corporation
;
; SPDX-License-Identifier: MIT
;
;============================ end_copyright_notice =============================
;
; RUN: %opt_typed_ptrs %use_old_pass_manager% -GenXGASDynamicResolution -march=genx64 -mcpu=Gen9 -S < %s | FileCheck %s --check-prefixes=CHECK,CHECK-TYPED-PTRS
; RUN: %opt_opaque_ptrs %use_old_pass_manager% -GenXGASDynamicResolution -march=genx64 -mcpu=Gen9 -S < %s | FileCheck %s --check-prefixes=CHECK,CHECK-OPAQUE-PTRS

target datalayout = "e-p:64:64-p3:32:32-i64:64-n8:16:32:64"

define spir_kernel void @kernel(i32 addrspace(1)* %global_buffer, i32 addrspace(3)* %local_buffer) #0 {
entry:
  br label %bb1
bb1:
  br label %bb2
bb2:
  %v = load i32, i32 addrspace(3)* %local_buffer, align 4
  %c = icmp ne i32 %v, 0
  br i1 %c, label %gen.to.as3, label %gen.to.as1
gen.to.as3:
  %generic_ptr_3 = addrspacecast i32 addrspace(3)* %local_buffer to i32 addrspace(4)*
  br label %body
gen.to.as1:
  %generic_ptr_1 = addrspacecast i32 addrspace(1)* %global_buffer to i32 addrspace(4)*
  br label %body
body:
  %generic_ptr = phi i32 addrspace(4)* [ %generic_ptr_1, %gen.to.as1 ], [ %generic_ptr_3, %gen.to.as3 ]
  ; CHECK-TYPED-PTRS: %generic_ptr = phi i32 addrspace(4)* [ %generic_ptr_1, %gen.to.as1 ], [ %generic_ptr_3.tagged, %gen.to.as3 ]
  ; CHECK-OPAQUE-PTRS: %generic_ptr = phi ptr addrspace(4) [ %generic_ptr_1, %gen.to.as1 ], [ %generic_ptr_3.tagged, %gen.to.as3 ]

  %ld = load i32, i32 addrspace(4)* %generic_ptr, align 4
  ; CHECK-TYPED-PTRS: %[[LD_CAST:.*]] = ptrtoint i32 addrspace(4)* %generic_ptr to i64
  ; CHECK-OPAQUE-PTRS: %[[LD_CAST:.*]] = ptrtoint ptr addrspace(4) %generic_ptr to i64
  ; CHECK: %[[LD_CAST_V:.*]] = bitcast i64  %[[LD_CAST:.*]] to <2 x i32>
  ; CHECK: %[[LD_TAG:.*]] = extractelement <2 x i32> %[[LD_CAST_V:.*]], i64 1
  ; CHECK: %isLocalTag = icmp eq i32 %[[LD_TAG:.*]], 1073741824
  ; CHECK: br i1 %isLocalTag, label %LocalBlock, label %GlobalBlock

  ; CHECK: LocalBlock:
  ; CHECK-TYPED-PTRS: %[[LOCAL_PTR:.*]] = addrspacecast i32 addrspace(4)* %generic_ptr to i32 addrspace(3)*
  ; CHECK-TYPED-PTRS: %localLoad = load i32, i32 addrspace(3)* %[[LOCAL_PTR:.*]], align 4
  ; CHECK-OPAQUE-PTRS: %[[LOCAL_PTR:.*]] = addrspacecast ptr addrspace(4) %generic_ptr to ptr addrspace(3)
  ; CHECK-OPAQUE-PTRS: %localLoad = load i32, ptr addrspace(3) %[[LOCAL_PTR:.*]], align 4

  ; CHECK: GlobalBlock:
  ; CHECK-TYPED-PTRS: %[[GLOBAL_PTR:.*]] = addrspacecast i32 addrspace(4)* %generic_ptr to i32 addrspace(1)*
  ; CHECK-TYPED-PTRS: %globalLoad = load i32, i32 addrspace(1)* %[[LOCAL_PTR:.*]], align 4
  ; CHECK-OPAQUE-PTRS: %[[GLOBAL_PTR:.*]] = addrspacecast ptr addrspace(4) %generic_ptr to ptr addrspace(1)
  ; CHECK-OPAQUE-PTRS: %globalLoad = load i32, ptr addrspace(1) %[[LOCAL_PTR:.*]], align 4

  ; CHECK: %ld = phi i32 [ %localLoad, %LocalBlock ], [ %globalLoad, %GlobalBlock ]

  br label %exit
exit:
  store i32 %ld, i32 addrspace(1)* %global_buffer, align 4
  ; CHECK-TYPED-PTRS: store i32 %ld, i32 addrspace(1)* %global_buffer, align 4
  ; CHECK-OPAQUE-PTRS: store i32 %ld, ptr addrspace(1) %global_buffer, align 4
  ret void
}

attributes #0 = { noinline nounwind "CMGenxMain" }
