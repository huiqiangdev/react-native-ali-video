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
  onBack?: () => void;
  /**
   * 是否隐藏返回按钮
   */
  isHiddenBack?: boolean;
  /**
   * 是否隐藏全屏返回按钮
   */
  isHiddenFullBack?: boolean;
};
