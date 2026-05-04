{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is JclUnicode.pas.                                                             }
{                                                                                                  }
{ The Initial Developer of the Original Code is Mike Lischke (public att lischke-online dott de).  }
{ Portions created by Mike Lischke are Copyright (C) 1999-2000 Mike Lischke. All Rights Reserved.  }
{                                                                                                  }
{ Contributor(s):                                                                                  }
{   Marcel van Brakel                                                                              }
{   Andreas Hausladen (ahuser)                                                                     }
{   Mike Lischke                                                                                   }
{   Flier Lu (flier)                                                                               }
{   Robert Marquardt (marquardt)                                                                   }
{   Robert Rossmair (rrossmair)                                                                    }
{   Olivier Sannier (obones)                                                                       }
{   Matthias Thoma (mthoma)                                                                        }
{   Petr Vones (pvones)                                                                            }
{   Peter Schraut (http://www.console-dev.de)                                                      }
{   Florent Ouchet (outchy)                                                                        }
{   glchapman                                                                                      }
{   Markus Humm (mhumm)                                                                            }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Various Unicode related routines                                                                 }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date::                                                                         $ }
{ Revision:      $Rev::                                                                          $ }
{ Author:        $Author::                                                                       $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclUnicode;

{$I jcl.inc}

// Copyright (c) 1999-2000 Mike Lischke (public att lischke-online dott de)
//

// 10-JUL-2005: (changes by Peter Schraut)
//   - added CodeBlockName, returns the blockname as string
//   - added CodeBlockRange, returns the range of the specified codeblock
//   - updated TUnicodeBlock to reflect changes in unicode 4.1
//   - updated CodeBlockFromChar to reflect changes in unicode 4.1
//   - Notes:
//      Here are a few suggestions to reflect latest namechanges in unicode 4.1,
//      but they were not done due to compatibility with old code:
//      ubGreek should be renamed to ubGreekandCoptic
//      ubCombiningMarksforSymbols should be renamed  to ubCombiningDiacriticalMarksforSymbols
//      ubPrivateUse should be renamed to ubPrivateUseArea
//
//
// 19-SEP-2003: (changes by Andreas Hausladen)
//   - added OWN_WIDESTRING_MEMMGR for faster memory managment in TWideStringList
//     under Windows
//   - fixed: TWideStringList.Destroy does not set OnChange and OnChanging to nil before calling Clear
//
//
// 29-MAR-2002: MT
//   - WideNormalize now returns strings with normalization mode nfNone unchanged.
//   - Bug fix in WideCompose: Raised exception when Result of WideComposeHangul was an
//     empty string. (#0000044)
//   - Bug fix in WideAdjustLineBreaks
//   - Added Asserts were needed.
//   - TWideStrings.IndexOfName now takes care of NormalizeForm as well.
//   - TWideStrings.IndexOf now takes care of NormalizeForm as well.
//   - TWideString.List Find now uses the same NormalizationForm for the search string as it uses
//     within the list itself.
//
// 29-NOV-2001:
//   - bug fix
// 06-JUN-2001:
//   - small changes
// 28-APR-2001:
//   - bug fixes
// 05-APR-2001:
//   - bug fixes
// 23-MAR-2001:
//   - WideSameText
//   - small changes
// 10-FEB-2001:
//   - bug fix in StringToWideStringEx and WideStringToStringEx
// 05-FEB-2001:
//   - TWideStrings.GetSeparatedText changed (no separator anymore after the last line)
// 29-JAN-2001:
//   - PrepareUnicodeData
//   - LoadInProgress critical section is now created at init time to avoid critical thread races
//   - bug fixes
// 26-JAN-2001:
//   - ExpandANSIString
//   - TWideStrings.SaveUnicode is by default True now
// 20..21-JAN-2001:
//   - StrUpperW, StrLowerW and StrTitleW removed because they potentially would need
//     a reallocation to work correctly (use the WideString versions instead)
//   - further improvements related to internal data
//   - introduced TUnicodeBlock
//   - CodeBlockFromChar improved
// 07-JAN-2001:
//   optimized access to character properties, combining class etc.
// 06-JAN-2001:
//   TWideStrings and TWideStringList improved
// APR-DEC 2000: versions 2.1 - 2.6
//   - preparation for public rlease
//   - additional conversion routines
//   - JCL compliance
//   - character properties unified
//   - character properties data and lookup improvements
//   - reworked Unicode data resource file
//   - improved simple string comparation routines (StrCompW, StrLCompW etc., include surrogate fix)
//   - special case folding data for language neutral case insensitive comparations included
//   - optimized decomposition
//   - composition and normalization support
//   - normalization conformance tests applied
//   - bug fixes
// FEB-MAR 2000: version 2.0
//   - Unicode regular expressions (URE) search class (TURESearch)
//   - generic search engine base class for both the Boyer-Moore and the RE search class
//   - whole word only search in UTBM, bug fixes in UTBM
//   - string decomposition (including hangul)
// OCT/99 - JAN/2000: version 1.0
//   - basic Unicode implementation, more than 100 WideString/UCS2 and UCS4 core functions
//   - TWideStrings and TWideStringList classes
//   - Unicode Tuned Boyer-Moore search class (TUTBMSearch)
//   - low and high level Unicode/Wide* functions
//   - low level Unicode UCS4 data import and functions
//   - helper functions
//
//  Version 2.9
// This unit contains routines and classes to manage and work with Unicode/WideString strings.
// You need Delphi 4 or higher to compile this code.
//
// Publicly available low level functions are all preceded by "Unicode..." (e.g.
// in UnicodeToUpper) while the high level functions use the Str... or Wide...
// naming scheme (e.g. StrLICompW and WideUpperCase).
//
// The normalization implementation in this unit has successfully and completely passed the
// official normative conformance testing as of Annex 9 in Technical Report #15
// (Unicode Standard Annex #15, http://www.unicode.org/unicode/reports/tr15, from 2000-08-31).
//
// Open issues:
//   - Yet to do things in the URE class are:
//     - check all character classes if they match correctly
//     - optimize rebuild of DFA (build only when pattern changes)
//     - set flag parameter of ExecuteURE
//     - add \d     any decimal digit
//           \D     any character that is not a decimal digit
//           \s     any whitespace character
//           \S     any character that is not a whitespace character
//           \w     any "word" character
//           \W     any "non-word" character
//   - The wide string classes still compare text with functions provided by the
//     particular system. This works usually fine under WinNT/W2K (although also
//     there are limitations like maximum text lengths). Under Win9x conversions
//     from and to MBCS are necessary which are bound to a particular locale and
//     so very limited in general use. These comparisons should be changed so that
//     the code in this unit is used.

interface

uses
  {$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.SysUtils, System.Classes,
  {$IFDEF HAS_UNIT_CHARACTER}
  System.Character,
  {$ENDIF HAS_UNIT_CHARACTER}
  {$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes,
  {$IFDEF HAS_UNIT_CHARACTER}
  Character,
  {$ENDIF HAS_UNIT_CHARACTER}
  {$ENDIF ~HAS_UNITSCOPE}
  JclBase;

{$IFNDEF FPC}
 {$IFDEF MSWINDOWS}
  {$DEFINE OWN_WIDESTRING_MEMMGR}
 {$ENDIF MSWINDOWS}
{$ENDIF ~FPC}

const
  // definitions of often used characters:
  // Note: Use them only for tests of a certain character not to determine character
  //       classes (like white spaces) as in Unicode are often many code points defined
  //       being in a certain class. Hence your best option is to use the various
  //       UnicodeIs* functions.
  WideNull = WideChar(#0);
  WideTabulator = WideChar(#9);
  WideSpace = WideChar(#32);

  // logical line breaks
  WideLF = WideChar(#10);
  WideLineFeed = WideChar(#10);
  WideVerticalTab = WideChar(#11);
  WideFormFeed = WideChar(#12);
  WideCR = WideChar(#13);
  WideCarriageReturn = WideChar(#13);
  WideCRLF = WideString(#13#10);
  WideLineSeparator = WideChar($2028);
  WideParagraphSeparator = WideChar($2029);

  // byte order marks for Unicode files
  // Unicode text files (in UTF-16 format) should contain $FFFE as first character to
  // identify such a file clearly. Depending on the system where the file was created
  // on this appears either in big endian or little endian style.
  BOM_LSB_FIRST = WideChar($FEFF);
  BOM_MSB_FIRST = WideChar($FFFE);

type
  TSaveFormat = ( sfUTF16LSB, sfUTF16MSB, sfUTF8, sfAnsi );

const
  sfUnicodeLSB = sfUTF16LSB;
  sfUnicodeMSB = sfUTF16MSB;

type
  // various predefined or otherwise useful character property categories
  TCharacterCategory = (
    // normative categories
    ccLetterUppercase,
    ccLetterLowercase,
    ccLetterTitlecase,
    ccMarkNonSpacing,
    ccMarkSpacingCombining,
    ccMarkEnclosing,
    ccNumberDecimalDigit,
    ccNumberLetter,
    ccNumberOther,
    ccSeparatorSpace,
    ccSeparatorLine,
    ccSeparatorParagraph,
    ccOtherControl,
    ccOtherFormat,
    ccOtherSurrogate,
    ccOtherPrivate,
    ccOtherUnassigned,
    // informative categories
    ccLetterModifier,
    ccLetterOther,
    ccPunctuationConnector,
    ccPunctuationDash,
    ccPunctuationOpen,
    ccPunctuationClose,
    ccPunctuationInitialQuote,
    ccPunctuationFinalQuote,
    ccPunctuationOther,
    ccSymbolMath,
    ccSymbolCurrency,
    ccSymbolModifier,
    ccSymbolOther,
    // bidirectional categories
    ccLeftToRight,
    ccLeftToRightEmbedding,
    ccLeftToRightOverride,
    ccRightToLeft,
    ccRightToLeftArabic,
    ccRightToLeftEmbedding,
    ccRightToLeftOverride,
    ccPopDirectionalFormat,
    ccEuropeanNumber,
    ccEuropeanNumberSeparator,
    ccEuropeanNumberTerminator,
    ccArabicNumber,
    ccCommonNumberSeparator,
    ccBoundaryNeutral,
    ccSegmentSeparator,      // this includes tab and vertical tab
    ccWhiteSpace,            // Separator characters and control characters which should be treated by programming languages as "white space" for the purpose of parsing elements.
    ccOtherNeutrals,
    ccLeftToRightIsolate,
    ccRightToLeftIsolate,
    ccFirstStrongIsolate,
    ccPopDirectionalIsolate,
    // self defined categories, they do not appear in the Unicode data file
    ccComposed,              // can be decomposed
    ccNonBreaking,
    ccSymmetric,             // has left and right forms
    ccHexDigit,              // Characters commonly used for the representation of hexadecimal numbers, plus their compatibility equivalents.
    ccQuotationMark,         // Punctuation characters that function as quotation marks.
    ccMirroring,
    ccAssigned,              // means there is a definition in the Unicode standard
    ccASCIIHexDigit,         // ASCII characters commonly used for the representation of hexadecimal numbers
    ccBidiControl,           // Format control characters which have specific functions in the Unicode Bidirectional Algorithm [UAX9].
    ccDash,                  // Punctuation characters explicitly called out as dashes in the Unicode Standard, plus their compatibility equivalents. Most of these have the General_Category value Pd, but some have the General_Category value Sm because of their use in mathematics.
    ccDeprecated,            // For a machine-readable list of deprecated characters. No characters will ever be removed from the standard, but the usage of deprecated characters is strongly discouraged.
    ccDiacritic,             // Characters that linguistically modify the meaning of another character to which they apply. Some diacritics are not combining characters, and some combining characters are not diacritics.
    ccExtender,              // Characters whose principal function is to extend the value or shape of a preceding alphabetic character. Typical of these are length and iteration marks.
    ccHyphen,                // Dashes which are used to mark connections between pieces of words, plus the Katakana middle dot. The Katakana middle dot functions like a hyphen, but is shaped like a dot rather than a dash.
    ccIdeographic,           // Characters considered to be CJKV (Chinese, Japanese, Korean, and Vietnamese) ideographs.
    ccIDSBinaryOperator,     // Used in Ideographic Description Sequences.
    ccIDSTrinaryOperator,    // Used in Ideographic Description Sequences.
    ccJoinControl,           // Format control characters which have specific functions for control of cursive joining and ligation.
    ccLogicalOrderException, // There are a small number of characters that do not use logical order. These characters require special handling in most processing.
    ccNonCharacterCodePoint, // Code points permanently reserved for internal use.
    ccOtherAlphabetic,       // Used in deriving the Alphabetic property.
    ccOtherDefaultIgnorableCodePoint, // Used in deriving the Default_Ignorable_Code_Point property.
    ccOtherGraphemeExtend,   // Used in deriving  the Grapheme_Extend property.
    ccOtherIDContinue,       // Used for backward compatibility of ID_Continue.
    ccOtherIDStart,          // Used for backward compatibility of ID_Start.
    ccOtherLowercase,        // Used in deriving the Lowercase property.
    ccOtherMath,             // Used in deriving the Math property.
    ccOtherUppercase,        // Used in deriving the Uppercase property.
    ccPatternSyntax,         // Used for pattern syntax as described in UAX #31: Unicode Identifier and Pattern Syntax [UAX31].
    ccPatternWhiteSpace,
    ccRadical,               // Used in Ideographic Description Sequences.
    ccSoftDotted,            // Characters with a "soft dot", like i or j. An accent placed on these characters causes the dot to disappear. An explicit dot above can be added where required, such as in Lithuanian.
    ccSTerm,                 // Sentence Terminal. Used in UAX #29: Unicode Text Segmentation [UAX29].
    ccTerminalPunctuation,   // Punctuation characters that generally mark the end of textual units.
    ccUnifiedIdeograph,      // Used in Ideographic Description Sequences.
    ccVariationSelector,     // Indicates characters that are Variation Selectors. For details on the behavior of these characters, see StandardizedVariants.html, Section 16.4, "Variation Selectors" in [Unicode], and the Unicode Ideographic Variation Database [UTS37].
    ccSentenceTerminal,      // Characters used at the end of a sentence
    ccPrependedQuotationMark,
    ccRegionalIndicator
  );
  TCharacterCategories = set of TCharacterCategory;

type
  // four forms of normalization are defined:
  TNormalizationForm = (
    nfNone, // do not normalize
    nfC,    // canonical decomposition followed by canonical composition (this is most often used)
    nfD,    // canonical decomposition
    nfKC,   // compatibility decomposition followed by a canonical composition
    nfKD    // compatibility decomposition
  );

  // 16 compatibility formatting tags are defined:
  TCompatibilityFormattingTag = (
    cftCanonical, // default when no CFT is explicited
    cftFont,      // Font variant (for example, a blackletter form)
    cftNoBreak,   // No-break version of a space or hyphen
    cftInitial,   // Initial presentation form (Arabic)
    cftMedial,    // Medial presentation form (Arabic)
    cftFinal,     // Final presentation form (Arabic)
    cftIsolated,  // Isolated presentation form (Arabic)
    cftCircle,    // Encircled form
    cftSuper,     // Superscript form
    cftSub,       // Subscript form
    cftVertical,  // Vertical layout presentation form
    cftWide,      // Wide (or zenkaku) compatibility character
    cftNarrow,    // Narrow (or hankaku) compatibility character
    cftSmall,     // Small variant form (CNS compatibility)
    cftSquare,    // CJK squared font variant
    cftFraction,  // Vulgar fraction form
    cftCompat     // Otherwise unspecified compatibility character
  );
  TCompatibilityFormattingTags = set of TCompatibilityFormattingTag;

  // used to hold information about the start and end
  // position of a unicodeblock.
  TUnicodeBlockRange = record
    RangeStart,
    RangeEnd: Cardinal;
  end;

  // An Unicode block usually corresponds to a particular language script but
  // can also represent special characters, musical symbols and the like.
  // https://www.unicode.org/charts/
  TUnicodeBlock = (
    ubUndefined,
    ubBasicLatin,
    ubLatin1Supplement,
    ubLatinExtendedA,
    ubLatinExtendedB,
    ubIPAExtensions,
    ubSpacingModifierLetters,
    ubCombiningDiacriticalMarks,
    ubGreekandCoptic,
    ubCyrillic,
    ubCyrillicSupplement,
    ubArmenian,
    ubHebrew,
    ubArabic,
    ubSyriac,
    ubArabicSupplement,
    ubThaana,
    ubNKo,
    ubSamaritan,
    ubMandaic,
    ubSyriacSupplement,
    ubArabicExtendedA,
    ubDevanagari,
    ubBengali,
    ubGurmukhi,
    ubGujarati,
    ubOriya,
    ubTamil,
    ubTelugu,
    ubKannada,
    ubMalayalam,
    ubSinhala,
    ubThai,
    ubLao,
    ubTibetan,
    ubMyanmar,
    ubGeorgian,
    ubHangulJamo,
    ubEthiopic,
    ubEthiopicSupplement,
    ubCherokee,
    ubUnifiedCanadianAboriginalSyllabics,
    ubOgham,
    ubRunic,
    ubTagalog,
    ubHanunoo,
    ubBuhid,
    ubTagbanwa,
    ubKhmer,
    ubMongolian,
    ubUnifiedCanadianAboriginalSyllabicsExtended,
    ubLimbu,
    ubTaiLe,
    ubNewTaiLue,
    ubKhmerSymbols,
    ubBuginese,
    ubTaiTham,
    ubCombiningDiactiticalMarksExtended,
    ubBalinese,
    ubSundanese,
    ubBatak,
    ubLepcha,
    ubOlChiki,
    ubCyrillicExtendedC,
    ubGeorgianExtended,
    ubSundaneseSupplement,
    ubVedicExtensions,
    ubPhoneticExtensions,
    ubPhoneticExtensionsSupplement,
    ubCombiningDiacriticalMarksSupplement,
    ubLatinExtendedAdditional,
    ubGreekExtended,
    ubGeneralPunctuation,
    ubSuperscriptsandSubscripts,
    ubCurrencySymbols,
    ubCombiningDiacriticalMarksforSymbols,
    ubLetterlikeSymbols,
    ubNumberForms,
    ubArrows,
    ubMathematicalOperators,
    ubMiscellaneousTechnical,
    ubControlPictures,
    ubOpticalCharacterRecognition,
    ubEnclosedAlphanumerics,
    ubBoxDrawing,
    ubBlockElements,
    ubGeometricShapes,
    ubMiscellaneousSymbols,
    ubDingbats,
    ubMiscellaneousMathematicalSymbolsA,
    ubSupplementalArrowsA,
    ubBraillePatterns,
    ubSupplementalArrowsB,
    ubMiscellaneousMathematicalSymbolsB,
    ubSupplementalMathematicalOperators,
    ubMiscellaneousSymbolsandArrows,
    ubGlagolitic,
    ubLatinExtendedC,
    ubCoptic,
    ubGeorgianSupplement,
    ubTifinagh,
    ubEthiopicExtended,
    ubCyrillicExtendedA,
    ubSupplementalPunctuation,
    ubCJKRadicalsSupplement,
    ubKangxiRadicals,
    ubIdeographicDescriptionCharacters,
    ubCJKSymbolsandPunctuation,
    ubHiragana,
    ubKatakana,
    ubBopomofo,
    ubHangulCompatibilityJamo,
    ubKanbun,
    ubBopomofoExtended,
    ubCJKStrokes,
    ubKatakanaPhoneticExtensions,
    ubEnclosedCJKLettersandMonths,
    ubCJKCompatibility,
    ubCJKUnifiedIdeographsExtensionA,
    ubYijingHexagramSymbols,
    ubCJKUnifiedIdeographs,
    ubYiSyllables,
    ubYiRadicals,
    ubLisu,
    ubVai,
    ubCyrillicExtendedB,
    ubBamum,
    ubModifierToneLetters,
    ubLatinExtendedD,
    ubSylotiNagri,
    ubCommonIndicNumberForms,
    ubPhagsPa,
    ubSaurashtra,
    ubDevanagariExtended,
    ubKayahLi,
    ubRejang,
    ubHangulJamoExtendedA,
    ubJavanese,
    ubMyanmarExtendedB,
    ubCham,
    ubMyanmarExtendedA,
    ubTaiViet,
    ubMeeteiMayekExtensions,
    ubEthiopicExtendedA,
    ubLatinExtendedE,
    ubCherokeeSupplement,
    ubMeeteiMayek,
    ubHangulSyllables,
    ubHangulJamoExtendedB,
    ubHighSurrogates,
    ubHighPrivateUseSurrogates,
    ubLowSurrogates,
    ubPrivateUseArea,
    ubCJKCompatibilityIdeographs,
    ubAlphabeticPresentationForms,
    ubArabicPresentationFormsA,
    ubVariationSelectors,
    ubVerticalForms,
    ubCombiningHalfMarks,
    ubCJKCompatibilityForms,
    ubSmallFormVariants,
    ubArabicPresentationFormsB,
    ubHalfwidthandFullwidthForms,
    ubSpecials,
    ubLinearBSyllabary,
    ubLinearBIdeograms,
    ubAegeanNumbers,
    ubAncientGreekNumbers,
    ubAncientSymbols,
    ubPhaistosDisc,
    ubLycian,
    ubCarian,
    ubCopticEpactNumbers,
    ubOldItalic,
    ubGothic,
    ubOldPermic,
    ubUgaritic,
    ubOldPersian,
    ubDeseret,
    ubShavian,
    ubOsmanya,
    ubOsage,
    ubElbasan,
    ubCaucasianAlbanian,
    ubLinearA,
    ubCypriotSyllabary,
    ubImperialAramaic,
    ubPalmyrene,
    ubNabataean,
    ubHatran,
    ubPhoenician,
    ubLydian,
    ubMeroiticHieroglyphs,
    ubMeroiticCursive,
    ubKharoshthi,
    ubOldSouthArabian,
    ubOldNorthArabian,
    ubManichaean,
    ubAvestan,
    ubInscriptionalParthian,
    ubInscriptionalPahlavi,
    ubPsalterPahlavi,
    ubOldTurkic,
    ubOldHungarian,
    ubHanifiRohingya,
    ubRumiNumeralSymbols,
    ubYezidi,
    ubOldSogdian,
    ubSogdian,
    ubChorasmian,
    ubElymaic,
    ubBrahmi,
    ubKaithi,
    ubSoraSompeng,
    ubChakma,
    ubMahajani,
    ubSharada,
    ubSinhalaArchaicNumbers,
    ubKhojki,
    ubMultani,
    ubKhudawadi,
    ubGrantha,
    ubNewa,
    ubTirhuta,
    ubSiddam,
    ubModi,
    ubMongolianSupplement,
    ubTakri,
    ubAhom,
    ubDogra,
    ubWarangCiti,
    ubDivesAkuru,
    ubNandinagari,
    ubZanabazarSquare,
    ubSoyombo,
    ubPauCinHau,
    ubBhaiksuki,
    ubMarchen,
    ubMasaramGondi,
    ubGunjalaGondi,
    ubTamilSupplement,
    ubMakasar,
    ubLisuSupplement,
    ubCuneiform,
    ubCuneiformNumbersAndPunctuation,
    ubEarlyDynasticCuneiform,
    ubEgyptianHieroglyphs,
    ubEgyptianHieroglyphFormatControls,
    ubAnatolianHieroglyphs,
    ubBamumSupplement,
    ubMro,
    ubBassaVah,
    ubPahawhHmong,
    ubMedefaidrin,
    ubMiao,
    upIdeographicSymbolsAndPunctuation,
    ubTangut,
    ubTangutComponents,
    ubKhitanSmallScript,
    ubTangutSupplement,
    ubKanaSupplement,
    ubKanaExtendedA,
    ubSmallKanaExtension,
    ubNushu,
    ubDuployan,
    ubShorthandFormatControls,
    ubByzantineMusicalSymbols,
    ubMusicalSymbols,
    ubAncientGreekMusicalNotation,
    ubMayanNumerals,
    ubTaiXuanJingSymbols,
    ubCountingRodNumerals,
    ubSuttonSignWriting,
    ubMathematicalAlphanumericSymbols,
    ubGlagolithicSupplement,
    ubWancho,
    ubNyiakengPuachueHmong,
    ubMendeKikakui,
    ubIndicSiyaqNumbers,
    ubOttomanSiyaqNumbers,
    ubAdlam,
    ubArabicMathematicalAlphabeticSymbols,
    ubMahjongTiles,
    ubDominoTiles,
    ubPlayingCards,
    ubEnclosedAlphanumericSupplement,
    ubEnclosedIdeographicSupplement,
    ubMiscellaneousSymbolsAndPictographs,
    ubEmoticons,
    ubOrnamentalDingbats,
    ubTransportAndMapSymbols,
    ubAlchemicalSymbols,
    ubGeometricShapesExtended,
    ubSupplementalArrowsC,
    ubSupplementalSymbolsAndPictographs,
    ubChessSymbols,
    ubSymbolsAndPictographsExtendedA,
    ubSymbolsForLegacyComputing,
    ubCJKUnifiedIdeographsExtensionB,
    ubCJKUnifiedIdeographsExtensionC,
    ubCJKUnifiedIdeographsExtensionD,
    ubCJKUnifiedIdeographsExtensionE,
    ubCJKUnifiedIdeographsExtensionF,
    ubCJKCompatibilityIdeographsSupplement,
    ubCJKUnifiedIdeographsExtensionG,
    ubTags,
    ubVariationSelectorsSupplement,
    ubSupplementaryPrivateUseAreaA,
    ubSupplementaryPrivateUseAreaB
  );

  TUnicodeBlockData = record
    Range: TUnicodeBlockRange;
    Name: string;
  end;
  PUnicodeBlockData = ^TUnicodeBlockData;

const
  UnicodeBlockData: array [TUnicodeBlock] of TUnicodeBlockData =
    ((Range:(RangeStart: $FFFFFFFF; RangeEnd: $0000); Name: 'No-block'),
    (Range:(RangeStart: $0000; RangeEnd: $007F); Name: 'Basic Latin'),
    (Range:(RangeStart: $0080; RangeEnd: $00FF); Name: 'Latin-1 Supplement'),
    (Range:(RangeStart: $0100; RangeEnd: $017F); Name: 'Latin Extended-A'),
    (Range:(RangeStart: $0180; RangeEnd: $024F); Name: 'Latin Extended-B'),
    (Range:(RangeStart: $0250; RangeEnd: $02AF); Name: 'IPA Extensions'),
    (Range:(RangeStart: $02B0; RangeEnd: $02FF); Name: 'Spacing Modifier Letters'),
    (Range:(RangeStart: $0300; RangeEnd: $036F); Name: 'Combining Diacritical Marks'),
    (Range:(RangeStart: $0370; RangeEnd: $03FF); Name: 'Greek and Coptic'),
    (Range:(RangeStart: $0400; RangeEnd: $04FF); Name: 'Cyrillic'),
    (Range:(RangeStart: $0500; RangeEnd: $052F); Name: 'Cyrillic Supplement'),
    (Range:(RangeStart: $0530; RangeEnd: $058F); Name: 'Armenian'),
    (Range:(RangeStart: $0590; RangeEnd: $05FF); Name: 'Hebrew'),
    (Range:(RangeStart: $0600; RangeEnd: $06FF); Name: 'Arabic'),
    (Range:(RangeStart: $0700; RangeEnd: $074F); Name: 'Syriac'),
    (Range:(RangeStart: $0750; RangeEnd: $077F); Name: 'Arabic Supplement'),
    (Range:(RangeStart: $0780; RangeEnd: $07BF); Name: 'Thaana'),
    (Range:(RangeStart: $07C0; RangeEnd: $07FF); Name: 'NKo'),
    (Range:(RangeStart: $0800; RangeEnd: $083F); Name: 'Samaritan'),
    (Range:(RangeStart: $0840; RangeEnd: $085F); Name: 'Mandaic'),
    (Range:(RangeStart: $0860; RangeEnd: $086F); Name: 'Syriac Supplement'),
    (Range:(RangeStart: $08A0; RangeEnd: $08FF); Name: 'Arabic Extended-A'),
    (Range:(RangeStart: $0900; RangeEnd: $097F); Name: 'Devanagari'),
    (Range:(RangeStart: $0980; RangeEnd: $09FF); Name: 'Bengali'),
    (Range:(RangeStart: $0A00; RangeEnd: $0A7F); Name: 'Gurmukhi'),
    (Range:(RangeStart: $0A80; RangeEnd: $0AFF); Name: 'Gujarati'),
    (Range:(RangeStart: $0B00; RangeEnd: $0B7F); Name: 'Oriya'),
    (Range:(RangeStart: $0B80; RangeEnd: $0BFF); Name: 'Tamil'),
    (Range:(RangeStart: $0C00; RangeEnd: $0C7F); Name: 'Telugu'),
    (Range:(RangeStart: $0C80; RangeEnd: $0CFF); Name: 'Kannada'),
    (Range:(RangeStart: $0D00; RangeEnd: $0D7F); Name: 'Malayalam'),
    (Range:(RangeStart: $0D80; RangeEnd: $0DFF); Name: 'Sinhala'),
    (Range:(RangeStart: $0E00; RangeEnd: $0E7F); Name: 'Thai'),
    (Range:(RangeStart: $0E80; RangeEnd: $0EFF); Name: 'Lao'),
    (Range:(RangeStart: $0F00; RangeEnd: $0FFF); Name: 'Tibetan'),
    (Range:(RangeStart: $1000; RangeEnd: $109F); Name: 'Myanmar'),
    (Range:(RangeStart: $10A0; RangeEnd: $10FF); Name: 'Georgian'),
    (Range:(RangeStart: $1100; RangeEnd: $11FF); Name: 'Hangul Jamo'),
    (Range:(RangeStart: $1200; RangeEnd: $137F); Name: 'Ethiopic'),
    (Range:(RangeStart: $1380; RangeEnd: $139F); Name: 'Ethiopic Supplement'),
    (Range:(RangeStart: $13A0; RangeEnd: $13FF); Name: 'Cherokee'),
    (Range:(RangeStart: $1400; RangeEnd: $167F); Name: 'Unified Canadian Aboriginal Syllabics'),
    (Range:(RangeStart: $1680; RangeEnd: $169F); Name: 'Ogham'),
    (Range:(RangeStart: $16A0; RangeEnd: $16FF); Name: 'Runic'),
    (Range:(RangeStart: $1700; RangeEnd: $171F); Name: 'Tagalog'),
    (Range:(RangeStart: $1720; RangeEnd: $173F); Name: 'Hanunoo'),
    (Range:(RangeStart: $1740; RangeEnd: $175F); Name: 'Buhid'),
    (Range:(RangeStart: $1760; RangeEnd: $177F); Name: 'Tagbanwa'),
    (Range:(RangeStart: $1780; RangeEnd: $17FF); Name: 'Khmer'),
    (Range:(RangeStart: $1800; RangeEnd: $18AF); Name: 'Mongolian'),
    (Range:(RangeStart: $18B0; RangeEnd: $18FF); Name: 'Unified Canadian Aboriginal Syllabics Extended'),
    (Range:(RangeStart: $1900; RangeEnd: $194F); Name: 'Limbu'),
    (Range:(RangeStart: $1950; RangeEnd: $197F); Name: 'Tai Le'),
    (Range:(RangeStart: $1980; RangeEnd: $19DF); Name: 'New Tai Lue'),
    (Range:(RangeStart: $19E0; RangeEnd: $19FF); Name: 'Khmer Symbols'),
    (Range:(RangeStart: $1A00; RangeEnd: $1A1F); Name: 'Buginese'),
    (Range:(RangeStart: $1A20; RangeEnd: $1AAF); Name: 'Tai Tham'),
    (Range:(RangeStart: $1AB0; RangeEnd: $1AFF); Name: 'Combining Diacritical Marks Extended'),
    (Range:(RangeStart: $1B00; RangeEnd: $1B7F); Name: 'Balinese'),
    (Range:(RangeStart: $1B80; RangeEnd: $1BBF); Name: 'Sundanese'),
    (Range:(RangeStart: $1BC0; RangeEnd: $1BFF); Name: 'Batak'),
    (Range:(RangeStart: $1C00; RangeEnd: $1C4F); Name: 'Lepcha'),
    (Range:(RangeStart: $1C50; RangeEnd: $1C7F); Name: 'Ol Chiki'),
    (Range:(RangeStart: $1C80; RangeEnd: $1C8F); Name: 'Cyrillic Extended-C'),
    (Range:(RangeStart: $1C90; RangeEnd: $1CBF); Name: 'Georgian Extended'),
    (Range:(RangeStart: $1CC0; RangeEnd: $1CCF); Name: 'Sundanese Supplement'),
    (Range:(RangeStart: $1CD0; RangeEnd: $1CFF); Name: 'Vedic Extensions'),
    (Range:(RangeStart: $1D00; RangeEnd: $1D7F); Name: 'Phonetic Extensions'),
    (Range:(RangeStart: $1D80; RangeEnd: $1DBF); Name: 'Phonetic Extensions Supplement'),
    (Range:(RangeStart: $1DC0; RangeEnd: $1DFF); Name: 'Combining Diacritical Marks Supplement'),
    (Range:(RangeStart: $1E00; RangeEnd: $1EFF); Name: 'Latin Extended Additional'),
    (Range:(RangeStart: $1F00; RangeEnd: $1FFF); Name: 'Greek Extended'),
    (Range:(RangeStart: $2000; RangeEnd: $206F); Name: 'General Punctuation'),
    (Range:(RangeStart: $2070; RangeEnd: $209F); Name: 'Superscripts and Subscripts'),
    (Range:(RangeStart: $20A0; RangeEnd: $20CF); Name: 'Currency Symbols'),
    (Range:(RangeStart: $20D0; RangeEnd: $20FF); Name: 'Combining Diacritical Marks for Symbols'),
    (Range:(RangeStart: $2100; RangeEnd: $214F); Name: 'Letterlike Symbols'),
    (Range:(RangeStart: $2150; RangeEnd: $218F); Name: 'Number Forms'),
    (Range:(RangeStart: $2190; RangeEnd: $21FF); Name: 'Arrows'),
    (Range:(RangeStart: $2200; RangeEnd: $22FF); Name: 'Mathematical Operators'),
    (Range:(RangeStart: $2300; RangeEnd: $23FF); Name: 'Miscellaneous Technical'),
    (Range:(RangeStart: $2400; RangeEnd: $243F); Name: 'Control Pictures'),
    (Range:(RangeStart: $2440; RangeEnd: $245F); Name: 'Optical Character Recognition'),
    (Range:(RangeStart: $2460; RangeEnd: $24FF); Name: 'Enclosed Alphanumerics'),
    (Range:(RangeStart: $2500; RangeEnd: $257F); Name: 'Box Drawing'),
    (Range:(RangeStart: $2580; RangeEnd: $259F); Name: 'Block Elements'),
    (Range:(RangeStart: $25A0; RangeEnd: $25FF); Name: 'Geometric Shapes'),
    (Range:(RangeStart: $2600; RangeEnd: $26FF); Name: 'Miscellaneous Symbols'),
    (Range:(RangeStart: $2700; RangeEnd: $27BF); Name: 'Dingbats'),
    (Range:(RangeStart: $27C0; RangeEnd: $27EF); Name: 'Miscellaneous Mathematical Symbols-A'),
    (Range:(RangeStart: $27F0; RangeEnd: $27FF); Name: 'Supplemental Arrows-A'),
    (Range:(RangeStart: $2800; RangeEnd: $28FF); Name: 'Braille Patterns'),
    (Range:(RangeStart: $2900; RangeEnd: $297F); Name: 'Supplemental Arrows-B'),
    (Range:(RangeStart: $2980; RangeEnd: $29FF); Name: 'Miscellaneous Mathematical Symbols-B'),
    (Range:(RangeStart: $2A00; RangeEnd: $2AFF); Name: 'Supplemental Mathematical Operators'),
    (Range:(RangeStart: $2B00; RangeEnd: $2BFF); Name: 'Miscellaneous Symbols and Arrows'),
    (Range:(RangeStart: $2C00; RangeEnd: $2C5F); Name: 'Glagolitic'),
    (Range:(RangeStart: $2C60; RangeEnd: $2C7F); Name: 'Latin Extended-C'),
    (Range:(RangeStart: $2C80; RangeEnd: $2CFF); Name: 'Coptic'),
    (Range:(RangeStart: $2D00; RangeEnd: $2D2F); Name: 'Georgian Supplement'),
    (Range:(RangeStart: $2D30; RangeEnd: $2D7F); Name: 'Tifinagh'),
    (Range:(RangeStart: $2D80; RangeEnd: $2DDF); Name: 'Ethiopic Extended'),
    (Range:(RangeStart: $2DE0; RangeEnd: $2DFF); Name: 'Cyrillic Extended-A'),
    (Range:(RangeStart: $2E00; RangeEnd: $2E7F); Name: 'Supplemental Punctuation'),
    (Range:(RangeStart: $2E80; RangeEnd: $2EFF); Name: 'CJK Radicals Supplement'),
    (Range:(RangeStart: $2F00; RangeEnd: $2FDF); Name: 'Kangxi Radicals'),
    (Range:(RangeStart: $2FF0; RangeEnd: $2FFF); Name: 'Ideographic Description Characters'),
    (Range:(RangeStart: $3000; RangeEnd: $303F); Name: 'CJK Symbols and Punctuation'),
    (Range:(RangeStart: $3040; RangeEnd: $309F); Name: 'Hiragana'),
    (Range:(RangeStart: $30A0; RangeEnd: $30FF); Name: 'Katakana'),
    (Range:(RangeStart: $3100; RangeEnd: $312F); Name: 'Bopomofo'),
    (Range:(RangeStart: $3130; RangeEnd: $318F); Name: 'Hangul Compatibility Jamo'),
    (Range:(RangeStart: $3190; RangeEnd: $319F); Name: 'Kanbun'),
    (Range:(RangeStart: $31A0; RangeEnd: $31BF); Name: 'Bopomofo Extended'),
    (Range:(RangeStart: $31C0; RangeEnd: $31EF); Name: 'CJK Strokes'),
    (Range:(RangeStart: $31F0; RangeEnd: $31FF); Name: 'Katakana Phonetic Extensions'),
    (Range:(RangeStart: $3200; RangeEnd: $32FF); Name: 'Enclosed CJK Letters and Months'),
    (Range:(RangeStart: $3300; RangeEnd: $33FF); Name: 'CJK Compatibility'),
    (Range:(RangeStart: $3400; RangeEnd: $4DBF); Name: 'CJK Unified Ideographs Extension A'),
    (Range:(RangeStart: $4DC0; RangeEnd: $4DFF); Name: 'Yijing Hexagram Symbols'),
    (Range:(RangeStart: $4E00; RangeEnd: $9FFC); Name: 'CJK Unified Ideographs'),
    (Range:(RangeStart: $A000; RangeEnd: $A48F); Name: 'Yi Syllables'),
    (Range:(RangeStart: $A490; RangeEnd: $A4CF); Name: 'Yi Radicals'),
    (Range:(RangeStart: $A4D0; RangeEnd: $A4FF); Name: 'Lisu'),
    (Range:(RangeStart: $A500; RangeEnd: $A63F); Name: 'Vai'),
    (Range:(RangeStart: $A640; RangeEnd: $A69F); Name: 'Cyrillic Extended-B'),
    (Range:(RangeStart: $A6A0; RangeEnd: $A6FF); Name: 'Bamum'),
    (Range:(RangeStart: $A700; RangeEnd: $A71F); Name: 'Modifier Tone Letters'),
    (Range:(RangeStart: $A720; RangeEnd: $A7FF); Name: 'Latin Extended-D'),
    (Range:(RangeStart: $A800; RangeEnd: $A82F); Name: 'Syloti Nagri'),
    (Range:(RangeStart: $A830; RangeEnd: $A83F); Name: 'Common Indic Number Forms'),
    (Range:(RangeStart: $A840; RangeEnd: $A87F); Name: 'Phags-pa'),
    (Range:(RangeStart: $A880; RangeEnd: $A8DF); Name: 'Saurashtra'),
    (Range:(RangeStart: $A8E0; RangeEnd: $A8FF); Name: 'Devanagari Extended'),
    (Range:(RangeStart: $A900; RangeEnd: $A92F); Name: 'Kayah Li'),
    (Range:(RangeStart: $A930; RangeEnd: $A95F); Name: 'Rejang'),
    (Range:(RangeStart: $A960; RangeEnd: $A97F); Name: 'Hangul Jamo Extended-A'),
    (Range:(RangeStart: $A980; RangeEnd: $A9DF); Name: 'Javanese'),
    (Range:(RangeStart: $A9E0; RangeEnd: $A9FF); Name: 'Myanmar Extended-B'),
    (Range:(RangeStart: $AA00; RangeEnd: $AA5F); Name: 'Cham'),
    (Range:(RangeStart: $AA60; RangeEnd: $AA7F); Name: 'Myanmar Extended-A'),
    (Range:(RangeStart: $AA80; RangeEnd: $AADF); Name: 'Tai Viet'),
    (Range:(RangeStart: $AAE0; RangeEnd: $AAFF); Name: 'Meetei Mayek Extensions'),
    (Range:(RangeStart: $AB00; RangeEnd: $AB2F); Name: 'Ethiopic Extended-A'),
    (Range:(RangeStart: $AB30; RangeEnd: $AB6F); Name: 'Latin Extended-E'),
    (Range:(RangeStart: $AB70; RangeEnd: $ABBF); Name: 'Cherokee Supplement'),
    (Range:(RangeStart: $ABC0; RangeEnd: $ABFF); Name: 'Meetei Mayek'),
    (Range:(RangeStart: $AC00; RangeEnd: $D7AF); Name: 'Hangul Syllables'),
    (Range:(RangeStart: $D7B0; RangeEnd: $D7FF); Name: 'Hangul Jamo Extended-B'),
    (Range:(RangeStart: $D800; RangeEnd: $DB7F); Name: 'High Surrogates'),
    (Range:(RangeStart: $DB80; RangeEnd: $DBFF); Name: 'High Private Use Surrogates'),
    (Range:(RangeStart: $DC00; RangeEnd: $DFFF); Name: 'Low Surrogates'),
    (Range:(RangeStart: $E000; RangeEnd: $F8FF); Name: 'Private Use Area'),
    (Range:(RangeStart: $F900; RangeEnd: $FAFF); Name: 'CJK Compatibility Ideographs'),
    (Range:(RangeStart: $FB00; RangeEnd: $FB4F); Name: 'Alphabetic Presentation Forms'),
    (Range:(RangeStart: $FB50; RangeEnd: $FDFF); Name: 'Arabic Presentation Forms-A'),
    (Range:(RangeStart: $FE00; RangeEnd: $FE0F); Name: 'Variation Selectors'),
    (Range:(RangeStart: $FE10; RangeEnd: $FE1F); Name: 'Vertical Forms'),
    (Range:(RangeStart: $FE20; RangeEnd: $FE2F); Name: 'Combining Half Marks'),
    (Range:(RangeStart: $FE30; RangeEnd: $FE4F); Name: 'CJK Compatibility Forms'),
    (Range:(RangeStart: $FE50; RangeEnd: $FE6F); Name: 'Small Form Variants'),
    (Range:(RangeStart: $FE70; RangeEnd: $FEFF); Name: 'Arabic Presentation Forms-B'),
    (Range:(RangeStart: $FF00; RangeEnd: $FFEF); Name: 'Halfwidth and Fullwidth Forms'),
    (Range:(RangeStart: $FFF0; RangeEnd: $FFFF); Name: 'Specials'),
    (Range:(RangeStart: $10000; RangeEnd: $1007F); Name: 'Linear B Syllabary'),
    (Range:(RangeStart: $10080; RangeEnd: $100FF); Name: 'Linear B Ideograms'),
    (Range:(RangeStart: $10100; RangeEnd: $1013F); Name: 'Aegean Numbers'),
    (Range:(RangeStart: $10140; RangeEnd: $1018F); Name: 'Ancient Greek Numbers'),
    (Range:(RangeStart: $10190; RangeEnd: $101CF); Name: 'Ancient Symbols'),
    (Range:(RangeStart: $101D0; RangeEnd: $101FF); Name: 'Phaistos Disc'),
    (Range:(RangeStart: $10280; RangeEnd: $1029F); Name: 'Lycian'),
    (Range:(RangeStart: $102A0; RangeEnd: $102DF); Name: 'Carian'),
    (Range:(RangeStart: $102E0; RangeEnd: $102FF); Name: 'Coptic Epact Numbers'),
    (Range:(RangeStart: $10300; RangeEnd: $1032F); Name: 'Old Italic'),
    (Range:(RangeStart: $10330; RangeEnd: $1034F); Name: 'Gothic'),
    (Range:(RangeStart: $10350; RangeEnd: $1037F); Name: 'Old Permic'),
    (Range:(RangeStart: $10380; RangeEnd: $1039F); Name: 'Ugaritic'),
    (Range:(RangeStart: $103A0; RangeEnd: $103DF); Name: 'Old Persian'),
    (Range:(RangeStart: $10400; RangeEnd: $1044F); Name: 'Deseret'),
    (Range:(RangeStart: $10450; RangeEnd: $1047F); Name: 'Shavian'),
    (Range:(RangeStart: $10480; RangeEnd: $104AF); Name: 'Osmanya'),
    (Range:(RangeStart: $104B0; RangeEnd: $104FF); Name: 'Osage'),
    (Range:(RangeStart: $10500; RangeEnd: $1052F); Name: 'Elbasan'),
    (Range:(RangeStart: $10530; RangeEnd: $1056F); Name: 'Caucasian Albanian'),
    (Range:(RangeStart: $10600; RangeEnd: $1077F); Name: 'Linear A'),
    (Range:(RangeStart: $10800; RangeEnd: $1083F); Name: 'Cypriot Syllabary'),
    (Range:(RangeStart: $10840; RangeEnd: $1085F); Name: 'Imperial Aramaic'),
    (Range:(RangeStart: $10860; RangeEnd: $1087F); Name: 'Palmyrene'),
    (Range:(RangeStart: $10880; RangeEnd: $108AF); Name: 'Nabataean'),
    (Range:(RangeStart: $108E0; RangeEnd: $108FF); Name: 'Hatran'),
    (Range:(RangeStart: $10900; RangeEnd: $1091F); Name: 'Phoenician'),
    (Range:(RangeStart: $10920; RangeEnd: $1093F); Name: 'Lydian'),
    (Range:(RangeStart: $10980; RangeEnd: $1099F); Name: 'Meroitic Hieroglyphs'),
    (Range:(RangeStart: $109A0; RangeEnd: $109FF); Name: 'Meroitic Cursive'),
    (Range:(RangeStart: $10A00; RangeEnd: $10A5F); Name: 'Kharoshthi'),
    (Range:(RangeStart: $10A60; RangeEnd: $10A7F); Name: 'Old South Arabian'),
    (Range:(RangeStart: $10A80; RangeEnd: $10A9F); Name: 'Old North Arabian'),
    (Range:(RangeStart: $10AC0; RangeEnd: $10AFF); Name: 'Manichaean'),
    (Range:(RangeStart: $10B00; RangeEnd: $10B3F); Name: 'Avestan'),
    (Range:(RangeStart: $10B40; RangeEnd: $10B5F); Name: 'Inscriptional Parthian'),
    (Range:(RangeStart: $10B60; RangeEnd: $10B7F); Name: 'Inscriptional Pahlavi'),
    (Range:(RangeStart: $10B80; RangeEnd: $10BAF); Name: 'Psalter Pahlavi'),
    (Range:(RangeStart: $10C00; RangeEnd: $10C4F); Name: 'Old Turkic'),
    (Range:(RangeStart: $10C80; RangeEnd: $10CFF); Name: 'Old Hungarian'),
    (Range:(RangeStart: $10D00; RangeEnd: $10D3F); Name: 'Hanifi Rohingya'),
    (Range:(RangeStart: $10E60; RangeEnd: $10E7F); Name: 'Rumi Numeral Symbols'),
    (Range:(RangeStart: $10E80; RangeEnd: $10EBF); Name: 'Yezidi'),
    (Range:(RangeStart: $10F00; RangeEnd: $10F2F); Name: 'Old Sogdian'),
    (Range:(RangeStart: $10F30; RangeEnd: $10FAF); Name: 'Sogdian'),
    (Range:(RangeStart: $10FB0; RangeEnd: $10FDF); Name: 'Chorasmian'),
    (Range:(RangeStart: $10FE0; RangeEnd: $10FFF); Name: 'Elymaic'),
    (Range:(RangeStart: $11000; RangeEnd: $1107F); Name: 'Brahmi'),
    (Range:(RangeStart: $11080; RangeEnd: $110CF); Name: 'Kaithi'),
    (Range:(RangeStart: $110D0; RangeEnd: $110FF); Name: 'Sora Sompeng'),
    (Range:(RangeStart: $11100; RangeEnd: $1114F); Name: 'Chakma'),
    (Range:(RangeStart: $11150; RangeEnd: $1117F); Name: 'Mahajani'),
    (Range:(RangeStart: $11180; RangeEnd: $111DF); Name: 'Sharada'),
    (Range:(RangeStart: $111E0; RangeEnd: $111FF); Name: 'Sinhala Archaic Numbers'),
    (Range:(RangeStart: $11200; RangeEnd: $1124F); Name: 'Khojki'),
    (Range:(RangeStart: $11280; RangeEnd: $112AF); Name: 'Multani'),
    (Range:(RangeStart: $112B0; RangeEnd: $112FF); Name: 'Khudawadi'),
    (Range:(RangeStart: $11300; RangeEnd: $1137F); Name: 'Grantha'),
    (Range:(RangeStart: $11400; RangeEnd: $1147F); Name: 'Newa'),
    (Range:(RangeStart: $11480; RangeEnd: $114DF); Name: 'Tirhuta'),
    (Range:(RangeStart: $11580; RangeEnd: $115FF); Name: 'Siddam'),
    (Range:(RangeStart: $11600; RangeEnd: $1165F); Name: 'Modi'),
    (Range:(RangeStart: $11660; RangeEnd: $1167F); Name: 'Mongolian Supplement'),
    (Range:(RangeStart: $11680; RangeEnd: $116CF); Name: 'Takri'),
    (Range:(RangeStart: $11700; RangeEnd: $1173F); Name: 'Ahom'),
    (Range:(RangeStart: $11800; RangeEnd: $1184F); Name: 'Dogra'),
    (Range:(RangeStart: $118A0; RangeEnd: $118FF); Name: 'Warang Citi'),
    (Range:(RangeStart: $11900; RangeEnd: $1195F); Name: 'Dives Akuru'),
    (Range:(RangeStart: $119A0; RangeEnd: $119FF); Name: 'Nandinagari'),
    (Range:(RangeStart: $11A00; RangeEnd: $11A4F); Name: 'Zanabazar Square'),
    (Range:(RangeStart: $11A50; RangeEnd: $11AAF); Name: 'Soyombo'),
    (Range:(RangeStart: $11AC0; RangeEnd: $11AFF); Name: 'Pau Cin Hau'),
    (Range:(RangeStart: $11C00; RangeEnd: $11C6F); Name: 'Bhaiksuki'),
    (Range:(RangeStart: $11C70; RangeEnd: $11CBF); Name: 'Marchen'),
    (Range:(RangeStart: $11D00; RangeEnd: $11D5F); Name: 'Masaram Gondi'),
    (Range:(RangeStart: $11D60; RangeEnd: $11DAF); Name: 'Gunjala Gondi'),
    (Range:(RangeStart: $11EE0; RangeEnd: $11EFF); Name: 'Makasar'),
    (Range:(RangeStart: $11FB0; RangeEnd: $11FBF); Name: 'Lisu Supplement'),
    (Range:(RangeStart: $11FC0; RangeEnd: $11FFF); Name: 'Tamil Supplement'),
    (Range:(RangeStart: $12000; RangeEnd: $123FF); Name: 'Cuneiform'),
    (Range:(RangeStart: $12400; RangeEnd: $1247F); Name: 'Cuneiform Numbers and Punctuation'),
    (Range:(RangeStart: $12480; RangeEnd: $1254F); Name: 'Early Dynastic Cuneiform'),
    (Range:(RangeStart: $13000; RangeEnd: $1342F); Name: 'Egyptian Hieroglyphs'),
    (Range:(RangeStart: $13430; RangeEnd: $1343F); Name: 'Egyptian Hieroglyph Format Controls'),
    (Range:(RangeStart: $14400; RangeEnd: $1467F); Name: 'Anatolian Hieroglyphs'),
    (Range:(RangeStart: $16800; RangeEnd: $16A3F); Name: 'Bamum Supplement'),
    (Range:(RangeStart: $16A40; RangeEnd: $16A6F); Name: 'Mro'),
    (Range:(RangeStart: $16AD0; RangeEnd: $16AFF); Name: 'Bassa Vah'),
    (Range:(RangeStart: $16B00; RangeEnd: $16B8F); Name: 'Pahawh Hmong'),
    (Range:(RangeStart: $16E40; RangeEnd: $16E9F); Name: 'Medefaidrin'),
    (Range:(RangeStart: $16F00; RangeEnd: $16F9F); Name: 'Miao'),
    (Range:(RangeStart: $16FE0; RangeEnd: $16FFF); Name: 'Ideographic Symbols and Punctuation'),
    (Range:(RangeStart: $17000; RangeEnd: $187F7); Name: 'Tangut'),
    (Range:(RangeStart: $18800; RangeEnd: $18AFF); Name: 'Tangut Components'),
    (Range:(RangeStart: $18B00; RangeEnd: $18CFF); Name: 'Khitan Small Script'),
    (Range:(RangeStart: $18D00; RangeEnd: $18D08); Name: 'Tangut Supplement'),
    (Range:(RangeStart: $1B000; RangeEnd: $1B0FF); Name: 'Kana Supplement'),
    (Range:(RangeStart: $1B100; RangeEnd: $1B12F); Name: 'Kana Extended-A'),
    (Range:(RangeStart: $1B130; RangeEnd: $1B16F); Name: 'Small Kana Extension'),
    (Range:(RangeStart: $1B170; RangeEnd: $1B2FF); Name: 'Nushu'),
    (Range:(RangeStart: $1BC00; RangeEnd: $1BC9F); Name: 'Duployan'),
    (Range:(RangeStart: $1BCA0; RangeEnd: $1BCAF); Name: 'Shorthand Format Controls'),
    (Range:(RangeStart: $1D000; RangeEnd: $1D0FF); Name: 'Byzantine Musical Symbols'),
    (Range:(RangeStart: $1D100; RangeEnd: $1D1FF); Name: 'Musical Symbols'),
    (Range:(RangeStart: $1D200; RangeEnd: $1D24F); Name: 'Ancient Greek Musical Notation'),
    (Range:(RangeStart: $1D2E0; RangeEnd: $1D2FF); Name: 'Mayan Numerals'),
    (Range:(RangeStart: $1D300; RangeEnd: $1D35F); Name: 'Tai Xuan Jing Symbols'),
    (Range:(RangeStart: $1D360; RangeEnd: $1D37F); Name: 'Counting Rod Numerals'),
    (Range:(RangeStart: $1D400; RangeEnd: $1D7FF); Name: 'Mathematical Alphanumeric Symbols'),
    (Range:(RangeStart: $1D800; RangeEnd: $1DAAF); Name: 'Sutton SignWriting'),
    (Range:(RangeStart: $1E000; RangeEnd: $1E02F); Name: 'Glagolitic Supplement'),
    (Range:(RangeStart: $1E100; RangeEnd: $1E14F); Name: 'Nyiakeng Puachue Hmong'),
    (Range:(RangeStart: $1E2C0; RangeEnd: $1E2FF); Name: 'Wancho'),
    (Range:(RangeStart: $1E800; RangeEnd: $1E8DF); Name: 'Mende Kikakui'),
    (Range:(RangeStart: $1EC70; RangeEnd: $1ECBF); Name: 'Indic Siyaq Numbers'),
    (Range:(RangeStart: $1ED00; RangeEnd: $1ED4F); Name: 'Ottoman Siyaq Numbers'),
    (Range:(RangeStart: $1E900; RangeEnd: $1E95F); Name: 'Adlam'),
    (Range:(RangeStart: $1EE00; RangeEnd: $1EEFF); Name: 'Arabic Mathematical Alphabetic Symbols'),
    (Range:(RangeStart: $1F000; RangeEnd: $1F02F); Name: 'Mahjong Tiles'),
    (Range:(RangeStart: $1F030; RangeEnd: $1F09F); Name: 'Domino Tiles'),
    (Range:(RangeStart: $1F0A0; RangeEnd: $1F0FF); Name: 'Playing Cards'),
    (Range:(RangeStart: $1F100; RangeEnd: $1F1FF); Name: 'Enclosed Alphanumeric Supplement'),
    (Range:(RangeStart: $1F200; RangeEnd: $1F2FF); Name: 'Enclosed Ideographic Supplement'),
    (Range:(RangeStart: $1F300; RangeEnd: $1F5FF); Name: 'Miscellaneous Symbols And Pictographs'),
    (Range:(RangeStart: $1F600; RangeEnd: $1F64F); Name: 'Emoticons'),
    (Range:(RangeStart: $1F650; RangeEnd: $1F67F); Name: 'Ornamental Dingbats'),
    (Range:(RangeStart: $1F680; RangeEnd: $1F6FF); Name: 'Transport And Map Symbols'),
    (Range:(RangeStart: $1F700; RangeEnd: $1F77F); Name: 'Alchemical Symbols'),
    (Range:(RangeStart: $1F780; RangeEnd: $1F7FF); Name: 'Geometric Shapes Extended'),
    (Range:(RangeStart: $1F800; RangeEnd: $1F8FF); Name: 'Supplemental Arrows-C'),
    (Range:(RangeStart: $1F900; RangeEnd: $1F9FF); Name: 'Supplemental Symbols And Pictographs'),
    (Range:(RangeStart: $1FA00; RangeEnd: $1FA6F); Name: 'Chess Symbols'),
    (Range:(RangeStart: $1FA70; RangeEnd: $1FAFF); Name: 'Symbols and Pictographs Extended-A'),
    (Range:(RangeStart: $1FB00; RangeEnd: $1FBFF); Name: 'Symbols for Legacy Computing'),
    (Range:(RangeStart: $20000; RangeEnd: $2A6DD); Name: 'CJK Unified Ideographs Extension B'),
    (Range:(RangeStart: $2A700; RangeEnd: $2B734); Name: 'CJK Unified Ideographs Extension C'),
    (Range:(RangeStart: $2B740; RangeEnd: $2B81D); Name: 'CJK Unified Ideographs Extension D'),
    (Range:(RangeStart: $2B820; RangeEnd: $2CEA1); Name: 'CJK Unified Ideographs Extension E'),
    (Range:(RangeStart: $2CEB0; RangeEnd: $2EBE0); Name: 'CJK Unified Ideographs Extension F'),
    (Range:(RangeStart: $2F800; RangeEnd: $2FA1F); Name: 'CJK Compatibility Ideographs Supplement'),
    (Range:(RangeStart: $30000; RangeEnd: $3134A); Name: 'CJK Unified Ideographs Extension G'),
    (Range:(RangeStart: $E0000; RangeEnd: $E007F); Name: 'Tags'),
    (Range:(RangeStart: $E0100; RangeEnd: $E01EF); Name: 'Variation Selectors Supplement'),
    (Range:(RangeStart: $F0000; RangeEnd: $FFFFF); Name: 'Supplementary Private Use Area-A'),
    (Range:(RangeStart: $100000; RangeEnd: $10FFFF); Name: 'Supplementary Private Use Area-B'));


// functions involving Delphi wide strings
function WideAdjustLineBreaks(const S: WideString): WideString;
function WideCharPos(const S: WideString; const Ch: WideChar; const Index: SizeInt): SizeInt;  //az
function WideExtractQuotedStr(var Src: PWideChar; Quote: WideChar): WideString;
function WideQuotedStr(const S: WideString; Quote: WideChar): WideString;
function WideStringOfChar(C: WideChar; Count: SizeInt): WideString;

// case conversion function
type
  TCaseType = (ctFold, ctLower, ctTitle, ctUpper);

function WideLowerCase(C: WideChar): WideString; overload; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function WideLowerCase(const S: WideString): WideString; overload; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function WideUpperCase(C: WideChar): WideString; overload; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function WideUpperCase(const S: WideString): WideString; overload; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function WideTrim(const S: WideString): WideString;
function WideTrimLeft(const S: WideString): WideString;
function WideTrimRight(const S: WideString): WideString;

type
  // result type for number retrieval functions
  TUcNumber = record
    Numerator,
    Denominator: Integer;
  end;

// Low level character routines

function UnicodeToUpper(Code: UCS4): TUCS4Array;
function UnicodeToLower(Code: UCS4): TUCS4Array;

// Character test routines
function UnicodeIsAlpha(C: UCS4): Boolean;
function UnicodeIsDigit(C: UCS4): Boolean;
function UnicodeIsAlphaNum(C: UCS4): Boolean;
function UnicodeIsNumberOther(C: UCS4): Boolean;
function UnicodeIsCased(C: UCS4): Boolean;
function UnicodeIsControl(C: UCS4): Boolean;
function UnicodeIsSpace(C: UCS4): Boolean;
function UnicodeIsWhiteSpace(C: UCS4): Boolean;
function UnicodeIsBlank(C: UCS4): Boolean;
function UnicodeIsPunctuation(C: UCS4): Boolean;
function UnicodeIsGraph(C: UCS4): Boolean;
function UnicodeIsPrintable(C: UCS4): Boolean;
function UnicodeIsUpper(C: UCS4): Boolean;
function UnicodeIsLower(C: UCS4): Boolean;
function UnicodeIsTitle(C: UCS4): Boolean;
function UnicodeIsIsoControl(C: UCS4): Boolean;
function UnicodeIsFormatControl(C: UCS4): Boolean;
function UnicodeIsSymbol(C: UCS4): Boolean;
function UnicodeIsNumber(C: UCS4): Boolean;
function UnicodeIsNonSpacing(C: UCS4): Boolean;
function UnicodeIsOpenPunctuation(C: UCS4): Boolean;
function UnicodeIsClosePunctuation(C: UCS4): Boolean;
function UnicodeIsInitialPunctuation(C: UCS4): Boolean;
function UnicodeIsFinalPunctuation(C: UCS4): Boolean;

function UnicodeIsLetterNumber(C: UCS4): Boolean;
function UnicodeIsConnectionPunctuation(C: UCS4): Boolean;
function UnicodeIsDash(C: UCS4): Boolean;
function UnicodeIsMath(C: UCS4): Boolean;
function UnicodeIsCurrency(C: UCS4): Boolean;
function UnicodeIsModifierSymbol(C: UCS4): Boolean;
function UnicodeIsSpacingMark(C: UCS4): Boolean;
function UnicodeIsEnclosing(C: UCS4): Boolean;
function UnicodeIsPrivate(C: UCS4): Boolean;
function UnicodeIsSurrogate(C: UCS4): Boolean;
function UnicodeIsLineSeparator(C: UCS4): Boolean;
function UnicodeIsParagraphSeparator(C: UCS4): Boolean;
function UnicodeIsIdentifierStart(C: UCS4): Boolean;
function UnicodeIsIdentifierPart(C: UCS4): Boolean;
function UnicodeIsDefined(C: UCS4): Boolean;
function UnicodeIsUndefined(C: UCS4): Boolean;
function UnicodeIsHan(C: UCS4): Boolean;
function UnicodeIsHangul(C: UCS4): Boolean;

function UnicodeIsUnassigned(C: UCS4): Boolean;
function UnicodeIsLetterOther(C: UCS4): Boolean;
function UnicodeIsConnector(C: UCS4): Boolean;
function UnicodeIsPunctuationOther(C: UCS4): Boolean;
function UnicodeIsSymbolOther(C: UCS4): Boolean;

// Utility functions
{$IFDEF MSWINDOWS}
function CharSetFromLocale(Language: LCID): Byte;
function GetCharSetFromLocale(Language: LCID; out FontCharSet: Byte): Boolean;
function CodePageFromLocale(Language: LCID): Word;
{$ENDIF MSWINDOWS}
function CodeBlockName(const CB: TUnicodeBlock): string;
function CodeBlockRange(const CB: TUnicodeBlock): TUnicodeBlockRange;
function CodeBlockFromChar(const C: UCS4): TUnicodeBlock;
{$IFDEF MSWINDOWS}
function KeyboardCodePage: Word;
function KeyUnicode(C: Char): WideChar;
function StringToWideStringEx(const S: AnsiString; CodePage: Word): WideString;
function TranslateString(const S: AnsiString; CP1, CP2: Word): AnsiString;
function WideStringToStringEx(const WS: WideString; CodePage: Word): AnsiString;

type
  TCompareFunc = function (const W1, W2: WideString; Locale: LCID): Integer;

var
  WideCompareText: TCompareFunc;
{$ENDIF MSWINDOWS}

type
  EJclUnicodeError = class(EJclError);

// functions around TUCS4Array
function UCS4Array(Ch: UCS4): TUCS4Array;
function UCS4ArrayConcat(Left, Right: UCS4): TUCS4Array; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
procedure UCS4ArrayConcat(var Left: TUCS4Array; Right: UCS4); overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
procedure UCS4ArrayConcat(var Left: TUCS4Array; const Right: TUCS4Array); overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; const Right: TUCS4Array): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; Right: UCS4): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; const Right: AnsiString): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
function UCS4ArrayEquals(const Left: TUCS4Array; Right: AnsiChar): Boolean; overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}

implementation

uses
  System.RtlConsts, JclResources, JclSynch, JclSysUtils, JclSysInfo, JclStringConversions,
  JclWideStrings;

const
  {$IFDEF FPC} // declarations from unit [Rtl]Consts
  SDuplicateString = 'String list does not allow duplicates';
  SListIndexError = 'List index out of bounds (%d)';
  SSortedListError = 'Operation not allowed on sorted string list';
  {$ENDIF FPC}
  // some predefined sets to shorten parameter lists below and ease repeative usage
  ClassLetter = [ccLetterUppercase, ccLetterLowercase, ccLetterTitlecase, ccLetterModifier, ccLetterOther];
  ClassSpace = [ccSeparatorSpace];
  ClassPunctuation = [ccPunctuationConnector, ccPunctuationDash, ccPunctuationOpen, ccPunctuationClose,
    ccPunctuationOther, ccPunctuationInitialQuote, ccPunctuationFinalQuote];
  ClassMark = [ccMarkNonSpacing, ccMarkSpacingCombining, ccMarkEnclosing];
  ClassNumber = [ccNumberDecimalDigit, ccNumberLetter, ccNumberOther];
  ClassSymbol = [ccSymbolMath, ccSymbolCurrency, ccSymbolModifier, ccSymbolOther];
  ClassEuropeanNumber = [ccEuropeanNumber, ccEuropeanNumberSeparator, ccEuropeanNumberTerminator];

  // used to negate a set of categories
  ClassAll = [Low(TCharacterCategory)..High(TCharacterCategory)];

function UnicodeToUpper(Code: UCS4): TUCS4Array;
begin
  SetLength(Result, 1);
  Result[0] := Ord(TCharacter.ToUpper(Chr(Code)));
end;

function UnicodeToLower(Code: UCS4): TUCS4Array;
begin
  SetLength(Result, 1);
  Result[0] := Ord(TCharacter.ToLower(Chr(Code)));
end;

// exchanges in each character of the given string the low order and high order
// byte to go from LSB to MSB and vice versa.
// EAX contains address of string

function WideAdjustLineBreaks(const S: WideString): WideString;
var
  Source,
  SourceEnd,
  Dest: PWideChar;
begin
  Source := Pointer(S);
  SourceEnd := Source + Length(S);

  Source := Pointer(S);
  SetString(Result, nil, SourceEnd - Source);
  Dest := Pointer(Result);

  while Source < SourceEnd do
  begin
    case Source^ of
      WideLineFeed:
        begin
          Dest^ := WideLineSeparator;
          Inc(Dest);
          Inc(Source);
        end;
      WideCarriageReturn:
        begin
          Dest^ := WideLineSeparator;
          Inc(Dest);
          Inc(Source);
          if Source^ = WideLineFeed then
            Inc(Source);
        end;
    else
      Dest^ := Source^;
      Inc(Dest);
      Inc(Source);
    end;
  end;

  SetLength(Result, (TJclAddr(Dest) - TJclAddr(Result)) div 2);
end;

function WideQuotedStr(const S: WideString; Quote: WideChar): WideString;
// works like QuotedStr from SysUtils.pas but can insert any quotation character
var
  P, Src,
  Dest: PWideChar;
  AddCount: SizeInt;
begin
  AddCount := 0;
  P := StrScanW(PWideChar(S), Quote);
  while (P <> nil) do
  begin
    Inc(P);
    Inc(AddCount);
    P := StrScanW(P, Quote);
  end;

  if AddCount = 0 then
    Result := Quote + S + Quote
  else
  begin
    SetLength(Result, Length(S) + AddCount + 2);
    Dest := PWideChar(Result);
    Dest^ := Quote;
    Inc(Dest);
    Src := PWideChar(S);
    P := StrScanW(Src, Quote);
    repeat
      Inc(P);
      Move(Src^, Dest^, 2 * (P - Src));
      Inc(Dest, P - Src);
      Dest^ := Quote;
      Inc(Dest);
      Src := P;
      P := StrScanW(Src, Quote);
    until P = nil;
    P := StrEndW(Src);
    Move(Src^, Dest^, 2 * (P - Src));
    Inc(Dest, P - Src);
    Dest^ := Quote;
  end;
end;

function WideExtractQuotedStr(var Src: PWideChar; Quote: WideChar): WideString;
// extracts a string enclosed in quote characters given by Quote
var
  P, Dest: PWideChar;
  DropCount: SizeInt;
begin
  Result := '';
  if (Src = nil) or (Src^ <> Quote) then
    Exit;

  Inc(Src);
  DropCount := 1;
  P := Src;
  Src := StrScanW(Src, Quote);

  while Src <> nil do   // count adjacent pairs of quote chars
  begin
    Inc(Src);
    if Src^ <> Quote then
      Break;
    Inc(Src);
    Inc(DropCount);
    Src := StrScanW(Src, Quote);
  end;

  if Src = nil then
    Src := StrEndW(P);
  if (Src - P) <= 1 then
    Exit;

  if DropCount = 1 then
    SetString(Result, P, Src - P - 1)
  else
  begin
    SetLength(Result, Src - P - DropCount);
    Dest := PWideChar(Result);
    Src := StrScanW(P, Quote);
    while Src <> nil do
    begin
      Inc(Src);
      if Src^ <> Quote then
        Break;
      Move(P^, Dest^, 2 * (Src - P));
      Inc(Dest, Src - P);
      Inc(Src);
      P := Src;
      Src := StrScanW(Src, Quote);
    end;
    if Src = nil then
      Src := StrEndW(P);
    Move(P^, Dest^, 2 * (Src - P - 1));
  end;
end;

function WideStringOfChar(C: WideChar; Count: SizeInt): WideString;
// returns a string of Count characters filled with C
var
  I: SizeInt;
begin
  SetLength(Result, Count);
  for I := 1 to Count do
    Result[I] := C;
end;

function WideTrim(const S: WideString): WideString;
var
  I, L: SizeInt;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (UnicodeIsWhiteSpace(UCS4(S[I])) or UnicodeIsControl(UCS4(S[I]))) do
    Inc(I);
  if I > L then
    Result := ''
  else
  begin
    while UnicodeIsWhiteSpace(UCS4(S[L])) or UnicodeIsControl(UCS4(S[L])) do
      Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;

function WideTrimLeft(const S: WideString): WideString;
var
  I, L: SizeInt;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (UnicodeIsWhiteSpace(UCS4(S[I])) or UnicodeIsControl(UCS4(S[I]))) do
    Inc(I);
  Result := Copy(S, I, Maxint);
end;

function WideTrimRight(const S: WideString): WideString;
var
  I: SizeInt;
begin
  I := Length(S);
  while (I > 0) and (UnicodeIsWhiteSpace(UCS4(S[I])) or UnicodeIsControl(UCS4(S[I]))) do
    Dec(I);
  Result := Copy(S, 1, I);
end;

// returns the index of character Ch in S, starts searching at index Index
// Note: This is a quick memory search. No attempt is made to interpret either
// the given charcter nor the string (ligatures, modifiers, surrogates etc.)
// Code from Azret Botash.

function WideCharPos(const S: WideString; const Ch: WideChar; const Index: SizeInt): SizeInt;
var
  P, R: PWideChar;
begin
  if (Index > 0) and (Index <= Length(S)) then
  begin
    P := PWideChar(@S[Index]);
    R := StrScanW(P, Ch);
    if R <> nil then
      Result := R - P + Index
    else
      Result := 0;
  end
  else
    Result := 0;
end;

function WideLowerCase(C: WideChar): WideString;
begin
  Result := TCharacter.ToLower(C);
end;

function WideLowerCase(const S: WideString): WideString;
begin
  Result := TCharacter.ToLower(S);
end;

function WideUpperCase(C: WideChar): WideString;
begin
  Result := TCharacter.ToUpper(C);
end;

function WideUpperCase(const S: WideString): WideString;
begin
  Result := TCharacter.ToUpper(S);
end;

//----------------- character test routines --------------------------------------------------------

function UnicodeIsAlpha(C: UCS4): Boolean; // Is the character alphabetic?
begin
  Result := TCharacter.IsLetter(Chr(C));
end;

function UnicodeIsDigit(C: UCS4): Boolean; // Is the character a digit?
begin
  Result := TCharacter.IsDigit(Chr(C));
end;

function UnicodeIsAlphaNum(C: UCS4): Boolean; // Is the character alphabetic or a number?
begin
  Result := TCharacter.IsLetterOrDigit(Chr(C));
end;

function UnicodeIsNumberOther(C: UCS4): Boolean;
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherNumber;
end;

function UnicodeIsCased(C: UCS4): Boolean;
// Is the character a "cased" character, i.e. either lower case, title case or upper case
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucTitlecaseLetter, TUnicodeCategory.ucUppercaseLetter];
end;

function UnicodeIsControl(C: UCS4): Boolean;
// Is the character a control character?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucControl, TUnicodeCategory.ucFormat];
end;

function UnicodeIsSpace(C: UCS4): Boolean;
// Is the character a spacing character?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSpaceSeparator;
end;

function UnicodeIsWhiteSpace(C: UCS4): Boolean;
// Is the character a white space character (same as UnicodeIsSpace plus
// tabulator, new line etc.)?
begin
  Result := TCharacter.IsWhiteSpace(Chr(C));
end;

function UnicodeIsBlank(C: UCS4): Boolean;
// Is the character a space separator?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSpaceSeparator;
end;

function UnicodeIsPunctuation(C: UCS4): Boolean;
// Is the character a punctuation mark?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation];
end;

function UnicodeIsGraph(C: UCS4): Boolean;
// Is the character graphical?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucEnclosingMark,
     TUnicodeCategory.ucNonSpacingMark,
     TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber,
     TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation,
     TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol];
end;

function UnicodeIsPrintable(C: UCS4): Boolean;
// Is the character printable?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucEnclosingMark,
     TUnicodeCategory.ucNonSpacingMark,
     TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber,
     TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucConnectPunctuation, TUnicodeCategory.ucDashPunctuation,
     TUnicodeCategory.ucClosePunctuation, TUnicodeCategory.ucFinalPunctuation,
     TUnicodeCategory.ucInitialPunctuation, TUnicodeCategory.ucOtherPunctuation,
     TUnicodeCategory.ucOpenPunctuation,
     TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol,
     TUnicodeCategory.ucSpaceSeparator];
end;

function UnicodeIsUpper(C: UCS4): Boolean;
// Is the character already upper case?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUppercaseLetter;
end;

function UnicodeIsLower(C: UCS4): Boolean;
// Is the character already lower case?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLowercaseLetter;
end;

function UnicodeIsTitle(C: UCS4): Boolean;
// Is the character already title case?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucTitlecaseLetter;
end;

function UnicodeIsIsoControl(C: UCS4): Boolean;
// Is the character a C0 control character (< 32)?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucControl;
end;

function UnicodeIsFormatControl(C: UCS4): Boolean;
// Is the character a format control character?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucFormat;
end;

function UnicodeIsSymbol(C: UCS4): Boolean;
// Is the character a symbol?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucCurrencySymbol, TUnicodeCategory.ucModifierSymbol,
     TUnicodeCategory.ucMathSymbol, TUnicodeCategory.ucOtherSymbol];
end;

function UnicodeIsNumber(C: UCS4): Boolean;
// Is the character a number or digit?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucDecimalNumber, TUnicodeCategory.ucLetterNumber,
     TUnicodeCategory.ucOtherNumber];
end;

function UnicodeIsNonSpacing(C: UCS4): Boolean;
// Is the character non-spacing?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucNonSpacingMark;
end;

function UnicodeIsOpenPunctuation(C: UCS4): Boolean;
// Is the character an open/left punctuation (e.g. '[')?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOpenPunctuation;
end;

function UnicodeIsClosePunctuation(C: UCS4): Boolean;
// Is the character an close/right punctuation (e.g. ']')?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucClosePunctuation;
end;

function UnicodeIsInitialPunctuation(C: UCS4): Boolean;
// Is the character an initial punctuation (e.g. U+2018 LEFT SINGLE QUOTATION MARK)?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucInitialPunctuation;
end;

function UnicodeIsFinalPunctuation(C: UCS4): Boolean;
// Is the character a final punctuation (e.g. U+2019 RIGHT SINGLE QUOTATION MARK)?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucFinalPunctuation;
end;

function UnicodeIsLetterNumber(C: UCS4): Boolean;
// Is the character a number represented by a letter?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLetterNumber;
end;

function UnicodeIsConnectionPunctuation(C: UCS4): Boolean;
// Is the character connecting punctuation?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucConnectPunctuation;
end;

function UnicodeIsDash(C: UCS4): Boolean;
// Is the character a dash punctuation?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucDashPunctuation;
end;

function UnicodeIsMath(C: UCS4): Boolean;
// Is the character a math character?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucMathSymbol;
end;

function UnicodeIsCurrency(C: UCS4): Boolean;
// Is the character a currency character?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucCurrencySymbol;
end;

function UnicodeIsModifierSymbol(C: UCS4): Boolean;
// Is the character a modifier symbol?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucModifierSymbol;
end;

function UnicodeIsSpacingMark(C: UCS4): Boolean;
// Is the character a spacing mark?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLineSeparator, TUnicodeCategory.ucParagraphSeparator,
     TUnicodeCategory.ucSpaceSeparator];
end;

function UnicodeIsEnclosing(C: UCS4): Boolean;
// Is the character enclosing (i.e. enclosing box)?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucEnclosingMark;
end;

function UnicodeIsPrivate(C: UCS4): Boolean;
// Is the character from the Private Use Area?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucPrivateUse;
end;

function UnicodeIsSurrogate(C: UCS4): Boolean;
// Is the character one of the surrogate codes?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucSurrogate;
end;

function UnicodeIsLineSeparator(C: UCS4): Boolean;
// Is the character a line separator?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucLineSeparator;
end;

function UnicodeIsParagraphSeparator(C: UCS4): Boolean;
// Is th character a paragraph separator;
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucParagraphSeparator;
end;

function UnicodeIsIdentifierStart(C: UCS4): Boolean;
// Can the character begin an identifier?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucLetterNumber];
end;

function UnicodeIsIdentifierPart(C: UCS4): Boolean;
// Can the character appear in an identifier?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) in
    [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,
     TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,
     TUnicodeCategory.ucUppercaseLetter,
     TUnicodeCategory.ucLetterNumber, TUnicodeCategory.ucDecimalNumber,
     TUnicodeCategory.ucNonSpacingMark, TUnicodeCategory.ucCombiningMark,
     TUnicodeCategory.ucConnectPunctuation,
     TUnicodeCategory.ucFormat];
end;

function UnicodeIsDefined(C: UCS4): Boolean;
// Is the character defined (appears in one of the data files)?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) <> TUnicodeCategory.ucUnassigned;
end;

function UnicodeIsUndefined(C: UCS4): Boolean;
// Is the character undefined (not assigned in the Unicode database)?
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUnassigned;
end;

function UnicodeIsHan(C: UCS4): Boolean;
// Is the character a Han ideograph?
begin
  Result := ((C >= $4E00) and (C <= $9FFF))  or ((C >= $F900) and (C <= $FAFF));
end;

function UnicodeIsHangul(C: UCS4): Boolean;
// Is the character a pre-composed Hangul syllable?
begin
  Result := (C >= $AC00) and (C <= $D7FF);
end;

function UnicodeIsUnassigned(C: UCS4): Boolean;
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucUnassigned;
end;

function UnicodeIsLetterOther(C: UCS4): Boolean;
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherLetter;
end;

function UnicodeIsConnector(C: UCS4): Boolean;
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucConnectPunctuation;
end;

function UnicodeIsPunctuationOther(C: UCS4): Boolean;
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherPunctuation;
end;

function UnicodeIsSymbolOther(C: UCS4): Boolean;
begin
  Result := TCharacter.GetUnicodeCategory(Chr(C)) = TUnicodeCategory.ucOtherSymbol;
end;

// I need to fix a problem (introduced by MS) here. The first parameter can be a pointer
// (and is so defined) or can be a normal DWORD, depending on the dwFlags parameter.
// As usual, lpSrc has been translated to a var parameter. But this does not work in
// our case, hence the redeclaration of the function with a pointer as first parameter.

{$IFDEF MSWINDOWS}
function TranslateCharsetInfoEx(lpSrc: SizeInt; out lpCs: TCharsetInfo; dwFlags: DWORD): BOOL; stdcall;
  external 'gdi32.dll' name 'TranslateCharsetInfo';

function GetCharSetFromLocale(Language: LCID; out FontCharSet: Byte): Boolean;
const
  TCI_SRCLOCALE = $1000;
var
  CSI: TCharsetInfo;
begin
  Result := TranslateCharsetInfoEx(Language, CSI, TCI_SRCLOCALE);
  if Result then
    FontCharset := CSI.ciCharset;
end;

function CharSetFromLocale(Language: LCID): Byte;
begin
  if not GetCharSetFromLocale(Language, Result) then
    RaiseLastOSError;
end;

function CodePageFromLocale(Language: LCID): Word;
// determines the code page for a given locale
var
  Buf: array [0..6] of Char;
begin
  GetLocaleInfo(Language, LOCALE_IDefaultAnsiCodePage, Buf, 6);
  Result := StrToIntDef(Buf, GetACP);
end;

function KeyboardCodePage: Word;
begin
  Result := CodePageFromLocale(GetKeyboardLayout(0) and $FFFF);
end;

function KeyUnicode(C: Char): WideChar;
// converts the given character (as it comes with a WM_CHAR message) into its
// corresponding Unicode character depending on the active keyboard layout
begin
  MultiByteToWideChar(KeyboardCodePage, MB_USEGLYPHCHARS, @C, 1, @Result, 1);
end;
{$ENDIF MSWINDOWS}

function CodeBlockRange(const CB: TUnicodeBlock): TUnicodeBlockRange;
// http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
begin
  Result := UnicodeBlockData[CB].Range;
end;


// Names taken from http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
function CodeBlockName(const CB: TUnicodeBlock): string;
begin
  Result := UnicodeBlockData[CB].Name;
end;

// Returns an ID for the Unicode code block to which C belongs.
// If C does not belong to any of the defined blocks then ubUndefined is returned.
// Note: the code blocks listed here are based on Unicode Version 5.0.0
function CodeBlockFromChar(const C: UCS4): TUnicodeBlock;
// http://www.unicode.org/Public/5.0.0/ucd/Blocks.txt
var
  L, H, I: TUnicodeBlock;
begin
  Result := ubUndefined;
  L := ubBasicLatin;
  H := High(TUnicodeBlock);
  while L <= H do
  begin
    I := TUnicodeBlock((Cardinal(L) + Cardinal(H)) shr 1);
    if (C >= UnicodeBlockData[I].Range.RangeStart) and (C <= UnicodeBlockData[I].Range.RangeEnd) then
    begin
      Result := I;
      Break;
    end
    else
    if C < UnicodeBlockData[I].Range.RangeStart then
    begin
      Dec(I);
      H := I;
    end
    else
    begin
      Inc(I);
      L := I;
    end;
  end;
end;

{$IFDEF MSWINDOWS}
function CompareTextWin95(const W1, W2: WideString; Locale: LCID): SizeInt;
// special comparation function for Win9x since there's no system defined
// comparation function, returns -1 if W1 < W2, 0 if W1 = W2 or 1 if W1 > W2
var
  S1, S2: AnsiString;
  CP: Word;
  L1, L2: SizeInt;
begin
  L1 := Length(W1);
  L2 := Length(W2);
  SetLength(S1, L1);
  SetLength(S2, L2);
  CP := CodePageFromLocale(Locale);
  WideCharToMultiByte(CP, 0, PWideChar(W1), L1, PAnsiChar(S1), L1, nil, nil);
  WideCharToMultiByte(CP, 0, PWideChar(W2), L2, PAnsiChar(S2), L2, nil, nil);
  Result := CompareStringA(Locale, NORM_IGNORECASE, PAnsiChar(S1), Length(S1),
    PAnsiChar(S2), Length(S2)) - 2;
end;

function CompareTextWinNT(const W1, W2: WideString; Locale: LCID): SizeInt;
// Wrapper function for WinNT since there's no system defined comparation function
// in Win9x and we need a central comparation function for TWideStringList.
// Returns -1 if W1 < W2, 0 if W1 = W2 or 1 if W1 > W2
begin
  Result := CompareStringW(Locale, NORM_IGNORECASE, PWideChar(W1), Length(W1),
    PWideChar(W2), Length(W2)) - 2;
end;

function StringToWideStringEx(const S: AnsiString; CodePage: Word): WideString;
var
  InputLength,
  OutputLength: SizeInt;
begin
  InputLength := Length(S);
  OutputLength := MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, nil, 0);
  SetLength(Result, OutputLength);
  MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, PWideChar(Result), OutputLength);
end;

function WideStringToStringEx(const WS: WideString; CodePage: Word): AnsiString;
var
  InputLength,
  OutputLength: SizeInt;
begin
  InputLength := Length(WS);
  OutputLength := WideCharToMultiByte(CodePage, 0, PWideChar(WS), InputLength, nil, 0, nil, nil);
  SetLength(Result, OutputLength);
  WideCharToMultiByte(CodePage, 0, PWideChar(WS), InputLength, PAnsiChar(Result), OutputLength, nil, nil);
end;

function TranslateString(const S: AnsiString; CP1, CP2: Word): AnsiString;
begin
  Result:= WideStringToStringEx(StringToWideStringEx(S, CP1), CP2);
end;
{$ENDIF MSWINDOWS}

function UCS4Array(Ch: UCS4): TUCS4Array;
begin
  SetLength(Result, 1);
  Result[0] := Ch;
end;

function UCS4ArrayConcat(Left, Right: UCS4): TUCS4Array;
begin
  SetLength(Result, 2);
  Result[0] := Left;
  Result[1] := Right;
end;

procedure UCS4ArrayConcat(var Left: TUCS4Array; Right: UCS4);
var
  I: SizeInt;
begin
  I := Length(Left);
  SetLength(Left, I + 1);
  Left[I] := Right;
end;

procedure UCS4ArrayConcat(var Left: TUCS4Array; const Right: TUCS4Array);
var
  I, J: SizeInt;
begin
  I := Length(Left);
  J := Length(Right);
  SetLength(Left, I + J);
  Move(Right[0], Left[I], J * SizeOf(Right[0]));
end;

function UCS4ArrayEquals(const Left: TUCS4Array; const Right: TUCS4Array): Boolean;
var
  I: SizeInt;
begin
  I := Length(Left);
  Result := I = Length(Right);
  while Result do
  begin
    Dec(I);
    Result := (I >= 0) and (Left[I] = Right[I]);
  end;
  Result := I < 0;
end;

function UCS4ArrayEquals(const Left: TUCS4Array; Right: UCS4): Boolean;
begin
  Result := (Length(Left) = 1) and (Left[0] = Right);
end;

function UCS4ArrayEquals(const Left: TUCS4Array; const Right: AnsiString): Boolean;
var
  I: SizeInt;
begin
  I := Length(Left);
  Result := I = Length(Right);
  while Result do
  begin
    Dec(I);
    Result := (I >= 0) and (Left[I] = Ord(Right[I + 1]));
  end;
  Result := I < 0;
end;

function UCS4ArrayEquals(const Left: TUCS4Array; Right: AnsiChar): Boolean;
begin
  Result := (Length(Left) = 1) and (Left[0] = Ord(Right));
end;

{$IFDEF MSWINDOWS}
procedure PrepareUnicodeData;
// Prepares structures which are globally needed.
begin
  if (Win32Platform and VER_PLATFORM_WIN32_NT) <> 0 then
    @WideCompareText := @CompareTextWinNT
  else
    @WideCompareText := @CompareTextWin95;
end;
{$ENDIF MSWINDOWS}

initialization
  {$IFDEF MSWINDOWS}
  PrepareUnicodeData;
  {$ENDIF MSWINDOWS}

end.
