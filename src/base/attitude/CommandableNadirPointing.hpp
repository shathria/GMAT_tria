//$Id$
//------------------------------------------------------------------------------
//                            Commandable Nadir Pointing
//------------------------------------------------------------------------------
// GMAT: General Mission Analysis Tool.
//
// Author: Mike Stark// Created: 2022.03.10
//
/**
 * Class definition for the CommandableNadirPointing class.
 *
 * @note
 */
//------------------------------------------------------------------------------

#ifndef CommandableNadir_hpp
#define CommandableNadir_hpp

#include "gmatdefs.hpp"
#include "GmatBase.hpp"
#include "Kinematic.hpp"

class CommandableNadirPointing : public Kinematic
{
public:
   /// Constructor
   CommandableNadirPointing(const std::string &itsName = "");
   /// copy constructor
   CommandableNadirPointing(const CommandableNadirPointing& att);
   /// operator =
   CommandableNadirPointing& operator=(const CommandableNadirPointing& att);
   /// destructor
   virtual ~CommandableNadirPointing();
   
   /// Initialize the Nadir attitude
   virtual bool Initialize();

   /// inherited from GmatBase
   virtual GmatBase* Clone() const;
   
   //------------------------------------------------------------------------------
   // *** Functions overridden to allow parameter setting
   //     without referencing Attitude class
   //------------------------------------------------------------------------------

   // Method to get the attitude as a Quaternion
   virtual const Rvector&     GetQuaternion(Real atTime);
   
   // Method to get the attitude as a Direction Cosine Matrix
   virtual const Rmatrix33&   GetCosineMatrix(Real atTime);
   
   // parameter setting operations to override Attitude versions for
   // nadir-pointing parameters
   virtual Real        SetRealParameter(const Integer id,
                                        const Real value);
   virtual Real        SetRealParameter(const std::string &label,
                                        const Real value);
   virtual bool        SetStringParameter(const Integer id,
                                          const std::string &value);
   virtual bool        SetStringParameter(const std::string &label,
                                          const std::string &value);
   
   // use to set quaternion without re-initializing;
   // supports the setting of quaternion during mission sequence
   virtual const Rvector&    SetRvectorParameter(const Integer id,
                                                 const Rvector &value);
   virtual const Rmatrix&    SetRmatrixParameter(const Integer id,
                                                 const Rmatrix &value);
   
   // allow the setting of the quaternion from script's mission sequence
   virtual bool IsParameterCommandModeSettable(const Integer id) const;

protected:
   enum 
   {
      CommandableNadirPointingParamCount = KinematicParamCount
   };
   
   static const Real DENOMINATOR_TOLERANCE;
   
   // flag for first call to ComputeCosineMatrixAndAngularVelocity()
   bool      hasComputedFirstDCM;

   Rmatrix33 TRIAD(Rvector3& V1, Rvector3& V2, Rvector3& W1, Rvector3& W2);
   
   virtual void ComputeCosineMatrixAndAngularVelocity(Real atTime);
   virtual void ComputeCosineMatrixAndAngularVelocity(GmatTime &atTime);
   virtual std::vector<Rmatrix33> GetRotationMatrixDerivative
      (GmatTime &epochGT, CoordinateSystem *j2kCS);

private:
   // Default constructor - not implemented

};
#endif /*CommandableNadir_hpp*/
