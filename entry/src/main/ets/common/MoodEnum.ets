export enum MoodEnum {
  HAPPY = 'Happy',
  NORMAL= 'Normal',
  SAD = 'Sad',
  ANGRY='Angry',
  DEFAULT = 'Default'
}

const MOOD_VALUES: readonly MoodEnum[] = [
  MoodEnum.HAPPY,
  MoodEnum.SAD,
  MoodEnum.ANGRY,
  MoodEnum.NORMAL,
];

// Convert string → enum (safe)
export function toMood(value: string): MoodEnum {
  return (MOOD_VALUES as readonly string[]).includes(value) ? (value as MoodEnum) : MoodEnum.DEFAULT;
}