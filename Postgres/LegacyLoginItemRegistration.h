//
//  LegacyLoginItemRegistration.h
//  Postgres
// 
// 
// Created by Jakob Egger on 05.05.26.
// This code is released under the terms of the PostgreSQL License.
// 


void RegisterLegacyLoginItem(CFURLRef url);
void UnregisterLegacyLoginItem(CFURLRef url);
BOOL IsLoginItemRegistered(CFURLRef url);
