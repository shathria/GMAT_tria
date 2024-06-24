//$Id$
//------------------------------------------------------------------------------
//                           BRTSRangeAdapter
//------------------------------------------------------------------------------
// GMAT: General Mission Analysis Tool
//
// Copyright (c) 2002 - 2022 United States Government as represented by the
// Administrator of The National Aeronautics and Space Administration.
// All Other Rights Reserved.
//
// Developed jointly by NASA/GSFC and Thinking Systems, Inc. under the FDSS 
// contract, Task Order 28
//
// Author: Tuan D. Nguyen
// Created: July 14, 2020
/**
 * A measurement adapter for BRTS range measurement
 */
//------------------------------------------------------------------------------

#ifndef BRTSRangeAdapter_hpp
#define BRTSRangeAdapter_hpp

#include "RangeAdapterKm.hpp"

//#define USE_BRTS_MEASUREMENT_ANALYTICAL_SOLUTION
#ifdef USE_BRTS_MEASUREMENT_ANALYTICAL_SOLUTION
   #define CALCULATE_RANGERATE
#endif


/**
 * A measurement adapter for BRTS range measurement
 */
class ESTIMATION_API BRTSRangeAdapter: public RangeAdapterKm
{
public:
   BRTSRangeAdapter(const std::string& name);
   virtual ~BRTSRangeAdapter();
   BRTSRangeAdapter(const BRTSRangeAdapter& ra);
   BRTSRangeAdapter&      operator=(const BRTSRangeAdapter& ra);

   virtual GmatBase*    Clone() const;

   virtual void ComputeBiasAndNoise(const std::string& useMeasType,
      const Integer numTrip);

   virtual void ApplyBiasAndNoise(const std::string& useMeasType,
      const RealArray& corrections, 
      const RealArray& values);

   virtual const MeasurementData&
      CalculateMeasurement(bool withEvents = false,
      ObservationData* forObservation = NULL,
      std::vector<RampTableData>* rampTB = NULL,
      bool forSimulation = false);

   virtual const std::vector<RealArray>&
      CalculateMeasurementDerivatives(GmatBase *obj,
      Integer id);

   /// Parameter IDs for the BRTSRangeRateAdapter
   enum
   {
      BRTSRangeAdapterParamCount = RangeAdapterKmParamCount,
   };

};

#endif /* BRTSRangeAdapter_hpp */
