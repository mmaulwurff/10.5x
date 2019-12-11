/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2019
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
    switch (val)
    {
    case     0: mLabel = "(Play Tourism Deluxe instead!) x"; break;
    case     5: mLabel =                "(Anybody home?) x"; break;
    case   100: mLabel =                     "(Standard) x"; break;
    case   200: mLabel =               "(Double trouble) x"; break;
    case  1000: mLabel =                  "(Classic 10x) x"; break;
    case  1050: mLabel =                   "(Slaughter!) x"; break;
    case  2000: mLabel =        "(How did you get here?) x"; break;
    case 10000: mLabel =              "(Are you insane?) x"; break;
    default:    mLabel =                                "x"; break;
    }
  }

} // class OptionMenuItemX5Slider
