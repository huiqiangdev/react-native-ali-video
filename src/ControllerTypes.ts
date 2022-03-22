export type ControllerViewProps = {
  isFull: boolean;
  current: number;
  buffer: number;
  total: number;
  isError: boolean;
  isLoading: boolean;
  onSliderValueChange?: (value: number) => void;
  isStart: boolean;
  onPressedStart?: () => void;
  onPause?: () => void;
  onFull?: () => void;
  title?: string;
};
