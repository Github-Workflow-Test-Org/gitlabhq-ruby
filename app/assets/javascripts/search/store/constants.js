import { statusFilterData } from '~/search/sidebar/components/status_filter/data';
import { confidentialFilterData } from '~/search/sidebar/components/confidentiality_filter/data';
import { languageFilterData } from '~/search/sidebar/components/language_filter/data';
import { labelFilterData } from '~/search/sidebar/components/label_filter/data';

export const MAX_FREQUENT_ITEMS = 5;

export const MAX_FREQUENCY = 5;

export const GROUPS_LOCAL_STORAGE_KEY = 'global-search-frequent-groups';

export const PROJECTS_LOCAL_STORAGE_KEY = 'global-search-frequent-projects';

export const SIDEBAR_PARAMS = [
  statusFilterData.filterParam,
  confidentialFilterData.filterParam,
  languageFilterData.filterParam,
  labelFilterData.filterParam,
];

export const NUMBER_FORMATING_OPTIONS = { notation: 'compact', compactDisplay: 'short' };

export const ICON_MAP = {
  blobs: 'code',
  issues: 'issues',
  epics: 'epic',
  merge_requests: 'merge-request',
  commits: 'commit',
  notes: 'comments',
  milestones: 'clock',
  users: 'users',
  projects: 'project',
  wiki_blobs: 'book',
  snippet_titles: 'snippet',
};
