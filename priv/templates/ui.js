(function() {
  const route = S.data({});

  function updateRoute() {
    let loc = Hash.getQuery();
    loc.scope = Hash.getValue() || 'undefined'
    route(loc)
  }

  window.addEventListener('hashchange', updateRoute)

  function payload(obj) {
    let payload = {}
    for (const key in obj) {
      let value = obj[key];
      if (typeof value === 'object') {
        payload[key] = value.id;
      } else payload[key] = value;
    }
    return payload;
  }

  function scope(opts) {
    let page = opts.page || 1
    let limit = opts.page_size || 10
    let offset = (page - 1) * limit
    let q = opts.query || ''
    return `?q=${q}&limit=${limit}&offset=${offset}`
  }

  async function readItem(collection, id) {
    return await fetch(`/api/${collection}/${id}`, {
      method: 'GET'
    }).then((response) => {
      if (response.ok) return response.json();
      return Promise.reject(response);
    }).then((data) => {
      return { item: data, error: null }
    }).catch((error) => {
      return { item: null, error: error }
    })
  }

  async function createItem(collection, data) {
    return await fetch(`/api/${collection}`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json; charset=UTF-8'
      },
      body: JSON.stringify(payload(data))
    }).then((response) => {
      if (response.ok) return response.json();
      return Promise.reject(response);
    }).then((data) => {
      return { item: data, error: null }
    }).catch((error) => {
      return { item: data, error: error }
    })
  }

  async function updateItem(collection, id, data) {
    return await fetch(`/api/${collection}/${id}`, {
      method: 'PATCH',
      headers: {
        'content-type': 'application/json; charset=UTF-8'
      },
      body: JSON.stringify(payload(data))
    }).then((response) => {
      if (response.ok) return response.json();
      return Promise.reject(response);
    }).then((data) => {
      return { item: data, error: null }
    }).catch((error) => {
      return { item: data, error: error }
    })
  }

  async function deleteItem(collection, id) {
    return await fetch(`/api/${collection}/${id}`, {
      method: 'DELETE'
    }).then((response) => {
      if (response.ok) return {};
      return Promise.reject(response);
    }).then((data) => {
      return { item: data, error: null }
    }).catch((error) => {
      return { item: null, error: error }
    })
  }

  async function searchItems(collection, opts) {
    return await fetch(`/api/${collection}${scope(opts)}`, {
      method: 'GET',
    }).then((response) => {
      if (response.ok) return response.json();
      return Promise.reject(response);
    }).then((data) => {
      return { items: data, error: null }
    }).catch((error) => {
      return { items: [], error: error }
    })
  }

  function prop(object, path) {
    let temp = object;
    path.split(".").forEach(subPath => {
      temp = temp ? (temp[subPath] || null) : null
    });
    return temp;
  }

  function format(str, obj) {
    return str.replace(/\${(.*?)}/g, (x, g) => obj[g]);
  }

  function bindFields(el, item) {
    el
      .querySelectorAll('[data-field]')
      .forEach((child) => {
        let path = child.dataset.field;
        value = prop(item, path);
        child.textContent = value;
      });
  }

  function bindHrefs(el, item, onclick) {
    el
      .querySelectorAll('[data-href]')
      .forEach((child) => {
        let pattern = child.dataset.href;
        let newLocation = format(pattern, item);
        child.onclick = function() {
          onclick();
          window.location = newLocation;
        }
      });
  }

  function debounce(func, wait) {
    let timeout;

    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };

      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  };




  S.root(() => {
      <%= app_bindings %>
  })

  updateRoute()
})()
