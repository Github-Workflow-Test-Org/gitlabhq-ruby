import { SUCCESS } from '~/vue_merge_request_widget/components/deployment/constants';

export const mockDownstreamPipelinesRest = ({ includeSourceJobRetried = true } = {}) => [
  {
    id: 632,
    user: {
      id: 1,
      username: 'root',
      name: 'Administrator',
      state: 'active',
      avatar_url:
        'https://secure.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      web_url: 'https://gdk.test:3000/root',
      show_status: false,
      path: '/root',
    },
    active: false,
    coverage: null,
    source: 'parent_pipeline',
    source_job: {
      name: 'bridge_job',
      retried: includeSourceJobRetried ? false : null,
    },
    path: '/kitchen-sink/bakery/-/pipelines/632',
    details: {
      status: {
        icon: 'status_success',
        text: 'passed',
        label: 'passed',
        group: 'success',
        tooltip: 'passed',
        has_details: true,
        details_path: '/kitchen-sink/bakery/-/pipelines/632',
        illustration: null,
        favicon:
          '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
      },
    },
    project: {
      id: 21,
      name: 'bakery',
      full_path: '/kitchen-sink/bakery',
      full_name: 'kitchen-sink / bakery',
      refs_url: '/kitchen-sink/bakery/refs',
    },
  },
  {
    id: 633,
    user: {
      id: 1,
      username: 'root',
      name: 'Administrator',
      state: 'active',
      avatar_url:
        'https://secure.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      web_url: 'https://gdk.test:3000/root',
      show_status: false,
      path: '/root',
    },
    active: false,
    coverage: null,
    source: 'parent_pipeline',
    source_job: {
      name: 'bridge_job',
      retried: includeSourceJobRetried ? true : null,
    },
    path: '/kitchen-sink/bakery/-/pipelines/633',
    details: {
      status: {
        icon: 'status_success',
        text: 'passed',
        label: 'passed',
        group: 'success',
        tooltip: 'passed',
        has_details: true,
        details_path: '/kitchen-sink/bakery/-/pipelines/633',
        illustration: null,
        favicon:
          '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
      },
    },
    project: {
      id: 21,
      name: 'bakery',
      full_path: '/kitchen-sink/bakery',
      full_name: 'kitchen-sink / bakery',
      refs_url: '/kitchen-sink/bakery/refs',
    },
  },
];

export const artifacts = [
  {
    text: 'result.txt',
    url: 'bar',
    job_name: 'generate-artifact',
    job_path: 'bar',
  },
  {
    text: 'foo.txt',
    url: 'foo',
    job_name: 'foo-artifact',
    job_path: 'foo',
  },
];

export default {
  id: 132,
  iid: 22,
  assignee_id: null,
  author_id: 1,
  description: '',
  lock_version: null,
  milestone_id: null,
  position: 0,
  state: 'merged',
  title: 'Update README.md',
  updated_by_id: null,
  created_at: '2017-04-07T12:27:26.718Z',
  updated_at: '2017-04-07T15:39:25.852Z',
  time_estimate: 0,
  total_time_spent: 0,
  human_access: 'Maintainer',
  human_time_estimate: null,
  human_total_time_spent: null,
  in_progress_merge_commit_sha: null,
  merge_commit_sha: '53027d060246c8f47e4a9310fb332aa52f221775',
  short_merge_commit_sha: '53027d06',
  merge_error: null,
  merge_params: {
    force_remove_source_branch: null,
  },
  merge_status: 'can_be_merged',
  merge_user_id: null,
  pipelines_empty_svg_path: '/path/to/svg',
  source_branch: 'daaaa',
  source_branch_link: 'daaaa',
  source_project_id: 19,
  source_project_full_path: '/group1/project1',
  target_branch: 'main',
  target_project_id: 19,
  target_project_full_path: '/group2/project2',
  merge_request_add_ci_config_path: '/root/group2/project2/-/ci/editor',
  is_dismissed_suggest_pipeline: false,
  user_callouts_path: 'some/callout/path',
  suggest_pipeline_feature_id: 'suggest_pipeline',
  new_project_pipeline_path: '/group2/project2/pipelines/new',
  source_project_default_url: '/gitlab-org/html5-boilerplate.git',
  metrics: {
    merged_by: {
      name: 'Administrator',
      username: 'root',
      id: 1,
      state: 'active',
      avatar_url:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      web_url: 'http://localhost:3000/root',
    },
    merged_at: '2017-04-07T15:39:25.696Z',
    closed_by: null,
    closed_at: null,
  },
  author: {
    name: 'Administrator',
    username: 'root',
    id: 1,
    state: 'active',
    avatar_url: 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
    web_url: 'http://localhost:3000/root',
  },
  merge_user: null,
  diff_head_sha: '104096c51715e12e7ae41f9333e9fa35b73f385d',
  diff_head_commit_short_id: '104096c5',
  default_merge_commit_message:
    "Merge branch 'daaaa' into 'main'\n\nUpdate README.md\n\nSee merge request !22",
  pipeline: {
    id: 172,
    user: {
      name: 'Administrator',
      username: 'root',
      id: 1,
      state: 'active',
      avatar_url:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      web_url: 'http://localhost:3000/root',
    },
    active: false,
    coverage: '92.16',
    path: '/root/acets-app/pipelines/172',
    details: {
      artifacts: artifacts.map(({ text, url, ...rest }) => ({
        name: text,
        path: url,
        ...rest,
      })),
      status: {
        icon: 'status_success',
        favicon: 'favicon_status_success',
        text: 'passed',
        label: 'passed',
        group: 'success',
        has_details: true,
        details_path: '/root/acets-app/pipelines/172',
      },
      duration: null,
      finished_at: '2017-04-07T14:00:14.256Z',
      stages: [
        {
          name: 'build',
          title: 'build: failed',
          status: {
            icon: 'status_failed',
            favicon: 'favicon_status_failed',
            text: 'failed',
            label: 'failed',
            group: 'failed',
            has_details: true,
            details_path: '/root/acets-app/pipelines/172#build',
          },
          path: '/root/acets-app/pipelines/172#build',
          dropdown_path: '/root/acets-app/pipelines/172/stage.json?stage=build',
        },
        {
          name: 'review',
          title: 'review: skipped',
          status: {
            icon: 'status_skipped',
            favicon: 'favicon_status_skipped',
            text: 'skipped',
            label: 'skipped',
            group: 'skipped',
            has_details: true,
            details_path: '/root/acets-app/pipelines/172#review',
          },
          path: '/root/acets-app/pipelines/172#review',
          dropdown_path: '/root/acets-app/pipelines/172/stage.json?stage=review',
        },
      ],
      manual_actions: [
        {
          name: 'stop_review',
          path: '/root/acets-app/builds/1427/play',
          playable: false,
        },
      ],
    },
    flags: {
      latest: false,
      triggered: false,
      stuck: false,
      yaml_errors: false,
      retryable: true,
      cancelable: false,
      merge_request_pipeline: false,
      detached_merge_request_pipeline: true,
    },
    ref: {
      name: 'daaaa',
      path: '/root/acets-app/tree/daaaa',
      tag: false,
      branch: true,
    },
    merge_request: {
      iid: 1,
      path: '/root/detached-merge-request-pipelines/-/merge_requests/1',
      title: 'Update README.md',
      source_branch: 'feature-1',
      source_branch_path: '/root/detached-merge-request-pipelines/branches/feature-1',
      target_branch: 'main',
      target_branch_path: '/root/detached-merge-request-pipelines/branches/main',
    },
    commit: {
      id: '104096c51715e12e7ae41f9333e9fa35b73f385d',
      short_id: '104096c5',
      title: 'Update README.md',
      created_at: '2017-04-07T15:27:18.000+03:00',
      parent_ids: ['2396536178668d8930c29d904e53bd4d06228b32'],
      message: 'Update README.md',
      author_name: 'Administrator',
      author_email: 'admin@example.com',
      authored_date: '2017-04-07T15:27:18.000+03:00',
      committer_name: 'Administrator',
      committer_email: 'admin@example.com',
      committed_date: '2017-04-07T15:27:18.000+03:00',
      author: {
        name: 'Administrator',
        username: 'root',
        id: 1,
        state: 'active',
        avatar_url:
          'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
        web_url: 'http://localhost:3000/root',
      },
      author_gravatar_url:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      commit_url:
        'http://localhost:3000/root/acets-app/commit/104096c51715e12e7ae41f9333e9fa35b73f385d',
      commit_path: '/root/acets-app/commit/104096c51715e12e7ae41f9333e9fa35b73f385d',
    },
    retry_path: '/root/acets-app/pipelines/172/retry',
    created_at: '2017-04-07T12:27:19.520Z',
    updated_at: '2017-04-07T15:28:44.800Z',
    triggered: mockDownstreamPipelinesRest(),
  },
  pipelineCoverageDelta: '15.25',
  buildsWithCoverage: [
    { name: 'karma', coverage: '40.2' },
    { name: 'rspec', coverage: '80.4' },
  ],
  work_in_progress: false,
  source_branch_exists: false,
  mergeable_discussions_state: true,
  conflicts_can_be_resolved_in_ui: false,
  branch_missing: true,
  commits_count: 1,
  has_conflicts: false,
  can_be_merged: true,
  has_ci: true,
  ci_status: 'success',
  pipeline_status_path: '/root/acets-app/-/merge_requests/22/pipeline_status',
  issues_links: {
    closing: '',
    mentioned_but_not_closing: '',
  },
  current_user: {
    can_resolve_conflicts: true,
    can_remove_source_branch: false,
    can_revert_on_current_merge_request: true,
    can_cherry_pick_on_current_merge_request: true,
  },
  blob_path: {
    base_path: 'blob_path',
    head_path: 'blob_path',
  },
  codequality_reports_path: '',
  codequality_help_path: 'code_quality.html',
  target_branch_path: '/root/acets-app/branches/main',
  source_branch_path: '/root/acets-app/branches/daaaa',
  conflict_resolution_ui_path: '/root/acets-app/-/merge_requests/22/conflicts',
  remove_wip_path: '/root/acets-app/-/merge_requests/22/remove_wip',
  cancel_auto_merge_path: '/root/acets-app/-/merge_requests/22/cancel_auto_merge',
  create_issue_to_resolve_discussions_path:
    '/root/acets-app/-/issues/new?merge_request_to_resolve_discussions_of=22',
  merge_path: '/root/acets-app/-/merge_requests/22/merge',
  cherry_pick_in_fork_path:
    '/root/acets-app/forks?continue%5Bnotice%5D=You%27re+not+allowed+to+make+changes+to+this+project+directly.+A+fork+of+this+project+has+been+created+that+you+can+make+changes+in%2C+so+you+can+submit+a+merge+request.+Try+to+revert+this+commit+again.&continue%5Bnotice_now%5D=You%27re+not+allowed+to+make+changes+to+this+project+directly.+A+fork+of+this+project+is+being+created+that+you+can+make+changes+in%2C+so+you+can+submit+a+merge+request.&continue%5Bto%5D=%2Froot%2Facets-app%2Fmerge_requests%2F22&namespace_key=1',
  revert_in_fork_path:
    '/root/acets-app/forks?continue%5Bnotice%5D=You%27re+not+allowed+to+make+changes+to+this+project+directly.+A+fork+of+this+project+has+been+created+that+you+can+make+changes+in%2C+so+you+can+submit+a+merge+request.+Try+to+cherry-pick+this+commit+again.&continue%5Bnotice_now%5D=You%27re+not+allowed+to+make+changes+to+this+project+directly.+A+fork+of+this+project+is+being+created+that+you+can+make+changes+in%2C+so+you+can+submit+a+merge+request.&continue%5Bto%5D=%2Froot%2Facets-app%2Fmerge_requests%2F22&namespace_key=1',
  email_patches_path: '/root/acets-app/-/merge_requests/22.patch',
  plain_diff_path: '/root/acets-app/-/merge_requests/22.diff',
  merge_request_basic_path: '/root/acets-app/-/merge_requests/22.json?serializer=basic',
  merge_request_widget_path: '/root/acets-app/-/merge_requests/22/widget.json',
  merge_request_cached_widget_path: '/cached.json',
  merge_check_path: '/root/acets-app/-/merge_requests/22/merge_check',
  ci_environments_status_path: '/root/acets-app/-/merge_requests/22/ci_environments_status',
  project_archived: false,
  default_merge_commit_message_with_description:
    "Merge branch 'daaaa' into 'main'\n\nUpdate README.md\n\nSee merge request !22",
  default_squash_commit_message: 'Test squash commit message',
  diverged_commits_count: 0,
  only_allow_merge_if_pipeline_succeeds: false,
  commit_change_content_path: '/root/acets-app/-/merge_requests/22/commit_change_content',
  merge_commit_path:
    'http://localhost:3000/root/acets-app/commit/53027d060246c8f47e4a9310fb332aa52f221775',
  mr_troubleshooting_docs_path: 'help',
  ci_troubleshooting_docs_path: 'help2',
  merge_request_pipelines_docs_path: '/help/ci/pipelines/merge_request_pipelines.md',
  squash: true,
  merge_trains_enabled: true,
  merge_trains_count: 3,
  merge_train_index: 1,
  security_reports_docs_path: 'security-reports-docs-path',
  sast_comparison_path: '/sast_comparison_path',
  secret_detection_comparison_path: '/secret_detection_comparison_path',
  gitpod_enabled: true,
  show_gitpod_button: true,
  gitpod_url: 'http://gitpod.localhost',
  user_preferences_gitpod_path: '/-/profile/preferences#user_gitpod_enabled',
  user_profile_enable_gitpod_path: '/-/user_settings/profile?user%5Bgitpod_enabled%5D=true',
};

export const mockStore = {
  pipeline: {
    id: 0,
    details: {
      artifacts,
      status: {
        details_path: '/root/review-app-tester/pipelines/66',
        favicon:
          '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2. png',
        group: 'success-with-warnings',
        has_details: true,
        icon: 'status_warning',
        illustration: null,
        label: 'passed with warnings',
        text: 'passed',
        tooltip: 'passed',
      },
    },
    flags: {},
    ref: {},
  },
  mergePipeline: {
    id: 1,
    details: {
      artifacts,
      status: {
        details_path: '/root/review-app-tester/pipelines/66',
        favicon:
          '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2. png',
        group: 'success-with-warnings',
        has_details: true,
        icon: 'status_warning',
        illustration: null,
        label: 'passed with warnings',
        text: 'passed',
        tooltip: 'passed',
      },
    },
    flags: {},
    ref: {},
  },
  targetBranch: 'target-branch',
  sourceBranch: 'source-branch',
  sourceBranchLink: 'source-branch-link',
  deployments: [
    {
      id: 0,
      name: 'bogus',
      external_url: 'https://fake.com',
      external_url_formatted: 'https://fake.com',
      status: SUCCESS,
      environment_available: true,
    },
    {
      id: 1,
      name: 'bogus-docs',
      external_url: 'https://fake.com',
      external_url_formatted: 'https://fake.com',
      status: SUCCESS,
      environment_available: true,
    },
  ],
  postMergeDeployments: [
    { id: 0, name: 'prod', status: SUCCESS },
    { id: 1, name: 'prod-docs', status: SUCCESS },
  ],
  mrTroubleshootingDocsPath: 'mr-troubleshooting-docs-path',
  ciTroubleshootingDocsPath: 'ci-troubleshooting-docs-path',
  ciStatus: 'ci-status',
  hasCI: true,
  exposedArtifactsPath: 'exposed_artifacts.json',
};

export const mockMergePipeline = {
  id: 127,
  user: {
    id: 1,
    name: 'Administrator',
    username: 'root',
    state: 'active',
    avatar_url: null,
    web_url: 'http://localhost:3000/root',
    status_tooltip_html: null,
    path: '/root',
  },
  active: true,
  coverage: null,
  source: 'push',
  created_at: '2018-10-22T11:41:35.186Z',
  updated_at: '2018-10-22T11:41:35.433Z',
  path: '/root/ci-web-terminal/pipelines/127',
  flags: {
    latest: true,
    stuck: true,
    auto_devops: false,
    yaml_errors: false,
    retryable: false,
    cancelable: true,
    failure_reason: false,
  },
  details: {
    status: {
      icon: 'status_pending',
      text: 'pending',
      label: 'pending',
      group: 'pending',
      tooltip: 'pending',
      has_details: true,
      details_path: '/root/ci-web-terminal/pipelines/127',
      illustration: null,
      favicon:
        '/assets/ci_favicons/favicon_status_pending-5bdf338420e5221ca24353b6bff1c9367189588750632e9a871b7af09ff6a2ae.png',
    },
    duration: null,
    finished_at: null,
    stages: [
      {
        name: 'test',
        title: 'test: pending',
        status: {
          icon: 'status_pending',
          text: 'pending',
          label: 'pending',
          group: 'pending',
          tooltip: 'pending',
          has_details: true,
          details_path: '/root/ci-web-terminal/pipelines/127#test',
          illustration: null,
          favicon:
            '/assets/ci_favicons/favicon_status_pending-5bdf338420e5221ca24353b6bff1c9367189588750632e9a871b7af09ff6a2ae.png',
        },
        path: '/root/ci-web-terminal/pipelines/127#test',
        dropdown_path: '/root/ci-web-terminal/pipelines/127/stage.json?stage=test',
      },
    ],
    artifacts: [],
    manual_actions: [],
    scheduled_actions: [],
  },
  ref: {
    name: 'main',
    path: '/root/ci-web-terminal/commits/main',
    tag: false,
    branch: true,
  },
  commit: {
    id: 'aa1939133d373c94879becb79d91828a892ee319',
    short_id: 'aa193913',
    title: "Merge branch 'main-test' into 'main'",
    created_at: '2018-10-22T11:41:33.000Z',
    parent_ids: [
      '4622f4dd792468993003caf2e3be978798cbe096',
      '76598df914cdfe87132d0c3c40f80db9fa9396a4',
    ],
    message:
      "Merge branch 'main-test' into 'main'\n\nUpdate .gitlab-ci.yml\n\nSee merge request root/ci-web-terminal!1",
    author_name: 'Administrator',
    author_email: 'admin@example.com',
    authored_date: '2018-10-22T11:41:33.000Z',
    committer_name: 'Administrator',
    committer_email: 'admin@example.com',
    committed_date: '2018-10-22T11:41:33.000Z',
    author: {
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatar_url: null,
      web_url: 'http://localhost:3000/root',
      status_tooltip_html: null,
      path: '/root',
    },
    author_gravatar_url: null,
    commit_url:
      'http://localhost:3000/root/ci-web-terminal/commit/aa1939133d373c94879becb79d91828a892ee319',
    commit_path: '/root/ci-web-terminal/commit/aa1939133d373c94879becb79d91828a892ee319',
  },
  cancel_path: '/root/ci-web-terminal/pipelines/127/cancel',
};

export const mockPostMergeDeployments = [
  {
    id: 15,
    name: 'review/diplo',
    url: '/root/acets-review-apps/environments/15',
    stop_url: '/root/acets-review-apps/environments/15/stop',
    metrics_url: '/root/acets-review-apps/environments/15/deployments/1/metrics',
    metrics_monitoring_url: '/root/acets-review-apps/environments/15/metrics',
    external_url: 'http://diplo.',
    external_url_formatted: 'diplo.',
    deployed_at: '2017-03-22T22:44:42.258Z',
    deployed_at_formatted: 'Mar 22, 2017 10:44pm',
    changes: [
      {
        path: 'index.html',
        external_url: 'http://root-main-patch-91341.volatile-watch.surge.sh/index.html',
      },
      {
        path: 'imgs/gallery.html',
        external_url: 'http://root-main-patch-91341.volatile-watch.surge.sh/imgs/gallery.html',
      },
      {
        path: 'about/',
        external_url: 'http://root-main-patch-91341.volatile-watch.surge.sh/about/',
      },
    ],
    status: 'success',
  },
];

export const mockDeployment = {
  id: 15,
  name: 'review/diplo',
  url: '/root/acets-review-apps/environments/15',
  stop_url: '/root/acets-review-apps/environments/15/stop',
  metrics_url: '/root/acets-review-apps/environments/15/deployments/1/metrics',
  metrics_monitoring_url: '/root/acets-review-apps/environments/15/metrics',
  external_url: 'http://diplo.',
  external_url_formatted: 'diplo.',
  deployed_at: '2017-03-22T22:44:42.258Z',
  deployed_at_formatted: 'Mar 22, 2017 10:44pm',
  changes: [
    {
      path: 'index.html',
      external_url: 'http://root-main-patch-91341.volatile-watch.surge.sh/index.html',
    },
    {
      path: 'imgs/gallery.html',
      external_url: 'http://root-main-patch-91341.volatile-watch.surge.sh/imgs/gallery.html',
    },
    {
      path: 'about/',
      external_url: 'http://root-main-patch-91341.volatile-watch.surge.sh/about/',
    },
  ],
  status: SUCCESS,
  environment_available: true,
};
