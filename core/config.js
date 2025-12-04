// var loc = window.location.pathname;
var dir = "./"; // Use relative path for better portability

export let config = {
  baseURL: dir,
  url(path) {
    return `${config.baseURL}${path}`;
  },
};

export function setConfig(options) {
  Object.assign(config, options);
}
