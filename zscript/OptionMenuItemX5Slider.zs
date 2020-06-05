/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2019-2020
 *
 * This file is a part of Typist.pk3.
 *
 * Typist.pk3 is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Typist.pk3 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Typist.pk3.  If not, see <https://www.gnu.org/licenses/>.
 */

class OptionMenuItemX5Slider : OptionMenuItemSlider
{

// public: /////////////////////////////////////////////////////////////////////

  OptionMenuItemX5Slider Init( String label
                             , Name   command
                             , double min
                             , double max
                             , double step
                             , int    showval = 1
                             )
  {
    Super.init(label, command, min, max, step, showval);
    setLabel(mCvar.getInt());
    return self;
  }

// public: // OptionMenuItemSlider /////////////////////////////////////////////

  override
  double getSliderValue()
  {
    return (mCVar.getInt() / 100.0);
  }

  override
  void setSliderValue(double val)
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

  private static
  String getSpecialLabel(int val)
  {
    switch(val)
    {
    case     0: return "X_000";
    case     5: return "X_005";
    case    50: return "X_050";
    case   100: return "X_100";
    case   200: return "X_200";
    case   400: return "X_400";
    case  1000: return "X_1000";
    case  1050: return "X_1050";
    case  2000: return "X_2000";
    case 10000: return "X_10000";
    default:    return "";
    }
  }

} // class OptionMenuItemX5Slider
