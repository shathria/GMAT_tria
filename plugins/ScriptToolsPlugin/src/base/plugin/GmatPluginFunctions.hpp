//$Id$
//------------------------------------------------------------------------------
//                            GmatPluginFunctions
//------------------------------------------------------------------------------
// GMAT: General Mission Analysis Tool
//
// Copyright (c) 2002 - 2022 United States Government as represented by the
// Administrator of the National Aeronautics and Space Administration.
// All Other Rights Reserved.
//
// Free usage granted to all users; this is shell code.  Adapt and enjoy.  
// Attribution is appreciated.
//
// Author: Joshua J. Raymond, Thinking Systems, Inc.
// Created: June 23, 2017
//
/**
* Definition for library code interfaces.
*/
//------------------------------------------------------------------------------
#ifndef GmatPluginFunctions_hpp
#define GmatPluginFunctions_hpp

#include "ScriptToolsDefs.hpp"
#include "Factory.hpp"

class MessageReceiver;

extern "C"
{
   Integer    ScriptTools_API GetFactoryCount();
   Factory    ScriptTools_API *GetFactoryPointer(Integer index);
   void       ScriptTools_API SetMessageReceiver(MessageReceiver* mr);
};


#endif /*GmatPluginFunctions_hpp*/
