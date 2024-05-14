import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import DesignPresentation from '~/work_items/components/design_management/design_preview/design_presentation.vue';
import DesignImage from '~/work_items/components/design_management/design_preview/image.vue';

const mockOverlayDimensions = {
  width: 100,
  height: 100,
};

describe('DesignPresentation', () => {
  let wrapper;

  const findDesignImage = () => wrapper.findComponent(DesignImage);

  function createComponent(props = {}, initialOverlayDimensions = mockOverlayDimensions, options) {
    wrapper = shallowMount(DesignPresentation, {
      propsData: {
        image: 'test.jpg',
        imageName: 'test',
        resolvedDiscussionsExpanded: false,
        discussions: [],
        isLoading: false,
        disableCommenting: false,
        ...props,
      },
      ...options,
    });

    if (initialOverlayDimensions) {
      findDesignImage().vm.$emit('resize', initialOverlayDimensions);
    }

    wrapper.element.scrollTo = jest.fn();
  }

  /**
   * Spy on $refs and mock given values
   * @param {Object} viewportDimensions {width, height}
   * @param {Object} childDimensions {width, height}
   * @param {Float} scrollTopPerc 0 < x < 1
   * @param {Float} scrollLeftPerc  0 < x < 1
   */
  function mockRefDimensions(
    ref,
    viewportDimensions,
    childDimensions,
    scrollTopPerc,
    scrollLeftPerc,
  ) {
    jest.spyOn(ref, 'scrollWidth', 'get').mockReturnValue(childDimensions.width);
    jest.spyOn(ref, 'scrollHeight', 'get').mockReturnValue(childDimensions.height);
    jest.spyOn(ref, 'offsetWidth', 'get').mockReturnValue(viewportDimensions.width);
    jest.spyOn(ref, 'offsetHeight', 'get').mockReturnValue(viewportDimensions.height);
    jest
      .spyOn(ref, 'scrollLeft', 'get')
      .mockReturnValue((childDimensions.width - viewportDimensions.width) * scrollLeftPerc);
    jest
      .spyOn(ref, 'scrollTop', 'get')
      .mockReturnValue((childDimensions.height - viewportDimensions.height) * scrollTopPerc);
  }

  it('renders image and overlay when image provided', async () => {
    createComponent({
      image: 'test.jpg',
      imageName: 'test',
    });

    await nextTick();
    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders empty state when no image provided', async () => {
    createComponent(
      {
        image: '',
        imageName: '',
      },
      null,
    );

    await nextTick();
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('getViewportCenter', () => {
    beforeEach(() => {
      createComponent({
        image: 'test.jpg',
        imageName: 'test',
      });
    });

    it('calculate center correctly with no scroll', () => {
      mockRefDimensions(
        wrapper.vm.$refs.presentationViewport,
        { width: 10, height: 10 },
        { width: 20, height: 20 },
        0,
        0,
      );

      expect(wrapper.vm.getViewportCenter()).toEqual({
        x: 5,
        y: 5,
      });
    });

    it('calculate center correctly with some scroll', () => {
      mockRefDimensions(
        wrapper.vm.$refs.presentationViewport,
        { width: 10, height: 10 },
        { width: 20, height: 20 },
        0.5,
        0.5,
      );

      expect(wrapper.vm.getViewportCenter()).toEqual({
        x: 10,
        y: 10,
      });
    });

    it('Returns default case if no overflow (scrollWidth==offsetWidth, etc.)', () => {
      mockRefDimensions(
        wrapper.vm.$refs.presentationViewport,
        { width: 20, height: 20 },
        { width: 20, height: 20 },
        0.5,
        0.5,
      );

      expect(wrapper.vm.getViewportCenter()).toEqual({
        x: 10,
        y: 10,
      });
    });
  });

  describe('scaleZoomFocalPoint', () => {
    it('scales focal point correctly when zooming in', () => {
      createComponent({
        image: 'test.jpg',
        imageName: 'test',
      });

      // setData usage is discouraged. See https://gitlab.com/groups/gitlab-org/-/epics/7330 for details
      // eslint-disable-next-line no-restricted-syntax
      wrapper.setData({
        zoomFocalPoint: {
          x: 5,
          y: 5,
          width: 50,
          height: 50,
        },
      });
      wrapper.vm.scaleZoomFocalPoint();
      expect(wrapper.vm.zoomFocalPoint).toEqual({
        x: 10,
        y: 10,
        width: 100,
        height: 100,
      });
    });

    it('scales focal point correctly when zooming out', () => {
      createComponent({
        image: 'test.jpg',
        imageName: 'test',
      });

      // setData usage is discouraged. See https://gitlab.com/groups/gitlab-org/-/epics/7330 for details
      // eslint-disable-next-line no-restricted-syntax
      wrapper.setData({
        zoomFocalPoint: {
          x: 10,
          y: 10,
          width: 200,
          height: 200,
        },
      });
      wrapper.vm.scaleZoomFocalPoint();
      expect(wrapper.vm.zoomFocalPoint).toEqual({
        x: 5,
        y: 5,
        width: 100,
        height: 100,
      });
    });
  });

  describe('onImageResize', () => {
    beforeEach(async () => {
      createComponent({
        image: 'test.jpg',
        imageName: 'test',
      });

      jest.spyOn(wrapper.vm, 'shiftZoomFocalPoint');
      jest.spyOn(wrapper.vm, 'scaleZoomFocalPoint');
      jest.spyOn(wrapper.vm, 'scrollToFocalPoint');
      wrapper.vm.onImageResize({ width: 10, height: 10 });
      await nextTick();
    });

    it('sets zoom focal point on initial load', () => {
      expect(wrapper.vm.shiftZoomFocalPoint).toHaveBeenCalled();
      expect(wrapper.vm.initialLoad).toBe(false);
    });

    it('calls scaleZoomFocalPoint and scrollToFocalPoint after initial load', async () => {
      wrapper.vm.onImageResize({ width: 10, height: 10 });
      await nextTick();
      expect(wrapper.vm.scaleZoomFocalPoint).toHaveBeenCalled();
      expect(wrapper.vm.scrollToFocalPoint).toHaveBeenCalled();
    });
  });
});
