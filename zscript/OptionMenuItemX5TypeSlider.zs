// SPDX-FileCopyrightText: 2023 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class OptionMenuItemX5TypeSlider : OptionMenuItemSlider
{
  OptionMenuItemX5TypeSlider Init(Class<Actor> type, String label)
  {
    Super.Init(label, "", 0, 10.5, 0.05, 2);
    mValue = 100;
    mType  = type;
    return self;
  }

  override double getSliderValue() { return (mValue / 100.0); }
  override void setSliderValue(double value) { mValue = int(round(value * 100)); }

  Class<Actor> getType() { return mType; }
  int getValue() { return mValue; }

  private int mValue;
  private Class<Actor> mType;
}

