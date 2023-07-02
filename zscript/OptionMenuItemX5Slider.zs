// SPDX-FileCopyrightText: 2019-2020 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class OptionMenuItemX5Slider : OptionMenuItemSlider
{

  OptionMenuItemX5Slider Init(String label,
                              Name command,
                              double min,
                              double max,
                              double step,
                              int showval = 1)
  {
    Super.init(label, command, min, max, step, showval);
    setLabel(mCvar.getInt());
    return self;
  }

  override double getSliderValue() { return (mCVar.getInt() / 100.0); }

  override void setSliderValue(double val)
  {
    int v = int(round(val * 100));
    mCvar.setInt(v);
    setLabel(v);
  }

  // private: ////////////////////////////////////////////////////////////////////

  private
  void setLabel(int val)
  {
    String specialLabel = getSpecialLabel(val);

    mLabel = (specialLabel.length() > 0)
           ? String.Format("(%s) x", StringTable.Localize(specialLabel, false))
           : "x";
  }

  private
  static String getSpecialLabel(int val)
  {
    switch (val)
    {
    case 0: return "X_000";
    case 5: return "X_005";
    case 50: return "X_050";
    case 100: return "X_100";
    case 200: return "X_200";
    case 400: return "X_400";
    case 1000: return "X_1000";
    case 1050: return "X_1050";
    case 2000: return "X_2000";
    case 10000: return "X_10000";
    default: return "";
    }
  }

} // class OptionMenuItemX5Slider
