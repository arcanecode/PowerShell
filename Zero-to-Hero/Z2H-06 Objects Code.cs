using System;

public class Z2HObjectExternal
{
  public static string composeFullName(string pSchema, string pTable)
  {
    string retVal = "";  // Using retVal for Write-Verbose purposes

    retVal = pSchema + "." + pTable;

    return retVal;

  } // public static void composeFullName
} // class Z2HObjectExternal
