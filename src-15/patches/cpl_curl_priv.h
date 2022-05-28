/******************************************************************************
 * $Id: cpl_curl_priv.h 818288a58e026803402172eaa5a53bcc31ebf7aa 2021-03-14 17:20:00 +0300 drons $
 *
 * Project:  CPL - Common Portability Library
 * Author:   Andrew Sudorgin (drons [a] list dot ru)
 *
 ******************************************************************************
 * Copyright (c) 2021, Andrew Sudorgin (drons [a] list dot ru)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ****************************************************************************/

#ifndef CPL_CURL_PRIV_H_INCLUDED
#define CPL_CURL_PRIV_H_INCLUDED

#include <curl/curl.h>

/*#ifndef CURL_AT_LEAST_VERSION*/
#define CURL_VERSION_BITS(x,y,z) ((x)<<16|(y)<<8|z)
#define CURL_AT_LEAST_VERSION(x,y,z) \
  (0x073300 >= CURL_VERSION_BITS(x, y, z))
/*#endif //#ifndef CURL_AT_LEAST_VERSION*/

#endif // CPL_CURL_PRIV_H_INCLUDED
