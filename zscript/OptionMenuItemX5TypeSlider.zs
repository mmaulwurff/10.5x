// SPDX-FileCopyrightText: 2023 Alexander Kromm <mmaulwurff@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

class OptionMenuItemX5TypeSlider : OptionMenuItemSlider
{
  void init(Class<Actor> type, int value)
  {
    let defaultEnemy = getDefaultByType(type);
    let tag = defaultEnemy.getTag();
    let label = String.Format("%s", tag);
    Super.Init(label, "", 0, 10.5, 0.05, 2);

    mValue = value;
    mType  = type;
  }

  override double getSliderValue() { return (mValue / 100.0); }
  override void setSliderValue(double value) { mValue = int(round(value * 100)); }

  Class<Actor> getType() { return mType; }
  int getValue() { return mValue; }

  private int mValue;
  private Class<Actor> mType;
}

