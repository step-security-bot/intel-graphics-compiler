#=========================== begin_copyright_notice ============================
#
# Copyright (C) 2017-2024 Intel Corporation
#
# SPDX-License-Identifier: MIT
#
#============================ end_copyright_notice =============================

add_subdirectory(TargetInfo)
add_subdirectory(Utils)

set(LLVM_TARGET_DEFINITIONS GenX.td)
tablegen(LLVM GenXGenSubtargetInfo.inc -gen-subtarget)
add_public_tablegen_target(GenXCommonTableGen)

set(GenXCommonTableGen_dependencies)
list(APPEND GenXCommonTableGen_dependencies
  GenXCommonTableGen)

add_custom_target(GenXCommonTableGen_target DEPENDS ${GenXCommonTableGen_dependencies})

set(CODEGEN_SOURCES
  ConstantEncoder.cpp
  FunctionGroup.cpp
  GenXAddressCommoning.cpp
  GenXAggregatePseudoLowering.cpp
  GenXAlignmentInfo.cpp
  GenXAnalysisDumper.cpp
  GenXArgIndirection.cpp
  GenXBaling.cpp
  GenXBiFPrepare.cpp
  GenXBFloatLowering.cpp
  GenXBuiltinFunctions.cpp
  GenXCFSimplification.cpp
  GenXCategory.cpp
  GenXCisaBuilder.cpp
  GenXCoalescing.cpp
  GenXConstants.cpp
  GenXDeadVectorRemoval.cpp
  GenXDebugInfo.cpp
  GenXDebugLegalization.cpp
  GenXDepressurizer.cpp
  GenXEmulate.cpp
  GenXExtractVectorizer.cpp
  GenXFixInvalidFuncName.cpp
  GenXFloatControl.cpp
  GenXLegalizeGVLoadUses.cpp
  GenXGASCastAnalyzer.cpp
  GenXGASDynamicResolution.cpp
  GenXGEPLowering.cpp
  GenXGlobalValueLowering.cpp
  GenXGotoJoin.cpp
  GenXGVClobberChecker.cpp
  GenXVerify.cpp
  GenXVerify_Regioning.cpp
  GenXIMadPostLegalization.cpp
  GenXInitBiFConstants.cpp
  GenXInlineAsmLowering.cpp
  GenXIntrinsics.cpp
  GenXLCECalculation.cpp
  GenXLegacyToLscTranslator.cpp
  GenXLegalization.cpp
  GenXLiveElements.cpp
  GenXLiveRanges.cpp
  GenXLiveness.cpp
  GenXLoadStoreLegalization.cpp
  GenXLoadStoreLowering.cpp
  GenXLowerAggrCopies.cpp
  GenXLowerJmpTableSwitch.cpp
  GenXLowering.cpp
  GenXLscAddrCalcFolding.cpp
  GenXModule.cpp
  GenXNumbering.cpp
  GenXOCLInfoExtractor.cpp
  GenXOCLRuntimeInfo.cpp
  GenXPatternMatch.cpp
  GenXPostLegalization.cpp
  GenXPredRegionLowering.cpp
  GenXPressureTracker.cpp
  GenXPrinter.cpp
  GenXPrologEpilogInsertion.cpp
  GenXPromoteArray.cpp
  GenXPromotePredicate.cpp
  GenXPromoteStatefulToBindless.cpp
  GenXRawSendRipper.cpp
  GenXReduceIntSize.cpp
  GenXRegionCollapsing.cpp
  GenXRegionUtils.cpp
  GenXRematerialization.cpp
  GenXSimdCFConformance.cpp
  GenXSimdCFRegion.cpp
  GenXSLMResolution.cpp
  GenXStackUsage.cpp
  GenXStructSplitter.cpp
  GenXSubtarget.cpp
  GenXTargetMachine.cpp
  GenXTidyControlFlow.cpp
  GenXUnbaling.cpp
  GenXUtil.cpp
  GenXVectorCombiner.cpp
  GenXVectorDecomposer.cpp
  GenXVisa.cpp
  GenXVisaRegAlloc.cpp
  OCLRuntimeInfoPrinter.cpp
  GenXGlobalUniform.cpp
  GenXDetectPointerArg.cpp
)

add_library(VCCodeGen STATIC ${CODEGEN_SOURCES})
add_dependencies(VCCodeGen
  GenXUtilBuild
  GenXCommonTableGen_target
  )
target_include_directories(VCCodeGen
  PRIVATE
  ${CMAKE_CURRENT_BINARY_DIR}
  )

igc_get_llvm_targets(LLVM_LIBS
  AggressiveInstCombine
  Analysis
  BitstreamReader
  BitReader
  BitWriter
  BinaryFormat
  CodeGen
  Core
  Demangle
  InstCombine
  Instrumentation
  ipo
  IRReader
  Linker
  Object
  ProfileData
  ScalarOpts
  Support
  Target
  TransformUtils
  Vectorize
  )

target_link_libraries(VCCodeGen
  ${LLVM_LIBS}

  LLVMGenXIntrinsics

  VCInternalIntrinsics

  VCHeaders
  VCTransforms
  VCTargetInfo
  VCSupport
  VCGeneralUtils
  VCGenXUtils
  BiFManager
  GenXDebugInfo
  GenX_IR
  )
