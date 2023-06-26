const token = S.data(null);

const state = S.data({
  collection: null,
  id: null,
  mode: null,
  children: null,
});

function stateFor(col, id, action, childAction, token) {
  let mode = 'list';
  if (id) {
    if (action === 'edit' || action === 'delete') {
      mode = action
    } else if (id === 'new') {
      mode = 'new';
    } else if (childAction) {
      mode = `${childAction}Child`
    } else {
      mode = 'show';
    }
  }

  return {
    collection: col,
    id:  (!id || id === 'new') ? null : id,
    mode: mode,
    children: (action == null || action === 'edit' || action === 'delete') ? null : action,
  }
}

function readToken() {
  return localStorage.getItem('pumpkin-token');
}

function setToken(t) {
  localStorage.setItem('pumpkin-token', t);
  token(t);
}

function deleteToken() {
  localStorage.removeItem('pumpkin-token');
  token(null);
}

function route() {
  let steps = window.location.hash.replace("#", "").split('/').filter(w => w.length > 0);
  state(stateFor(steps[0], steps[1], steps[2], steps[3], token));
}

function visit(location) {
  window.location.href = location;
}

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

function msg(resp) {
  switch (resp.status) {
    case 200: return {id: 1, severity: 'primary', text: 'Success'}
    case 201: return {id: 1, severity: 'primary', text: 'Success'}
    case 204: return {id: 1, severity: 'primary', text: 'Success'}
    case 400: return {id: 1, severity: 'warning', text: 'Please check your data'}
    case 404: return {id: 1, severity: 'warning', text: 'Not found'}
    case 409: return {id: 1, severity: 'warning', text: 'Already exists'}
    default: return {id: 1, severity: 'danger', text: 'Server error'}
  }
}

function scope(opts) {
  let page = opts.page || 1
  let limit = opts.page_size || 10
  let offset = (page - 1)*limit
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
    return {item: data, errors: []}
  }).catch((error) => {
    return {item: {}, errors: [msg(error)]}
  })
}

async function searchItems(collection, opts) {
  return await fetch(`/api/${collection}${scope(opts)}`, {
    method: 'GET',
  }).then((response) => {
    if (response.ok) return response.json();
    return Promise.reject(response);
  }).then((data) => {
    return {items: data, errors: []}
  }).catch((error) => {
    return {items: [], errors: [msg(error)]}
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
    return {item: data, errors: []}
  }).catch((error) => {
    return {item: data, errors: [msg(error)]}
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
    return {item: data, errors: []}
  }).catch((error) => {
    return {item: data, errors: [msg(error)]}
  })
}

async function deleteItem(collection, id) {
  return await fetch(`/api/${collection}/${id}`, {
    method: 'DELETE'
  }).then((response) => {
    if (response.ok) return {};
    return Promise.reject(response);
  }).then((data) => {
    return {item: {}, errors: []}
  }).catch((error) => {
    return {item: item, errors: [msg(error)]}
  })
}

async function aggregateChildren(collection, id, relation) {
  return await fetch(`/api/${collection}/${id}/${relation}/aggregate`, {
    method: 'GET'
  }).then((response) => {
    if (response.ok) return response.json();
    return Promise.reject(response);
  }).then((data) => {
    return {count: data.count, errors: []}
  }).catch((error) => {
    return {count: 0, errors: [msg(error)]}
  })
}

async function searchChildren(collection, id, relation, opts) {
  return await fetch(`/api/${collection}/${id}/${relation}${scope(opts)}`, {
    method: 'GET',
  }).then((response) => {
    if (response.ok) return response.json();
    return Promise.reject(response);
  }).then((data) => {
    return {items: data, errors: []}
  }).catch((error) => {
    return {items: [], errors: [msg(error)]}
  })
}

function prop(object, path) {
  let temp = object;

  path.split(".").forEach(subPath => {
    temp = temp ? (temp[subPath] || null) : null
  });

  return temp;
}




function bindClasses(parent) {
  parent
    .querySelectorAll('[data-class]')
    .forEach((el) => {
      el
        .getAttribute('data-class')
        .split(" ")
        .forEach((binding) => {
          binding = binding.split(":");
          let className = binding[0];
          let scope = binding[1];
          S(() => {
            let global = state();
            if (global.collection === scope) {
              el.classList.add(className);
            } else {
              el.classList.remove(className);
            }
          });
        });
    });
}

function bindDisplay(el, next) {
  let mode = el.dataset.mode;
  let scope = el.dataset.scope;

  S(() => {
    let global = state();
    let display = (global.collection == scope && global.mode == mode) ? '' : 'none';
    el.style.display = display;

    if (next && display != 'none') next();
  });
}

function bindPrivateMode(parent) {
  parent
    .querySelectorAll('[data-private')
    .forEach((el) => {
      S(() => el.style.display = token() ? '' : 'none');
    })
}

function bindPublicMode(parent) {
  parent
    .querySelectorAll('[data-public]')
    .forEach((el) => {
      S(() => el.style.display = token() ? 'none' : '');
    })
}

function setHref(el, data) {
  let url = el.dataset.link.split("/").map((part) => {
    if (!part.startsWith("$")) {
      return part;
    } else return prop(data, part.substring("1"))
  }).join("/");

  el.href = `#${url}`;
}

function setHrefs(el, data) {
  el
    .querySelectorAll('[data-link]')
    .forEach((el2) => setHref(el2, data));
}

function bindLinks(el, data) {
  S(() => {
    let item = data().item;
    setHrefs(el, item);
  });
}

function bindNavMode(parent) {
  parent
    .querySelectorAll('[data-mode="nav"]')
    .forEach((el) => {
      el
        .querySelectorAll('[data-show]')
        .forEach((el2) => {
          let modes = el2.dataset.show;
          S(() => {
            let d = state();
            let display = (modes === "*" || modes.includes(d.mode) || (modes === 'children' && d.children)) ? '' : 'none';
            el2.style.display = display;
          });
        });

      el
        .querySelectorAll('[data-text]')
        .forEach((el2) => {
          let field = el2.dataset.text
          S(() => {
            let d = state();
            el2.textContent = d[field] || field;
          });
        });

      el
        .querySelectorAll('[data-link]')
        .forEach((el2) => S(() => setHref(el2, state())));

    });
}

function bindForm(el, form) {
  el
    .querySelectorAll('[data-name]')
    .forEach((field) => {
      let path = field.dataset.name;

      field.addEventListener("change", (event) => {
        let f = form();
        f.item[path] = event.target.value;
        form(f);
      });

      S(() => {
        let f = form();
        let value = prop(f.item, path);
        field.value = value;
        field.textContent = value;
      });
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

function bindFilter(el, scope, collection) {
  el
    .querySelectorAll('[data-filter]')
    .forEach((el2) => {
      let form = S.data({query: ""});
      el2
        .querySelectorAll('[data-name="query"]')
        .forEach((input) => {
          input.onkeyup = debounce(async function() {
            let query = input.value;
            let {items, errors} = await searchItems(scope, {query: query});
            collection({items, errors});
          }, 300);
        });
    });
}

function bindChildrenMode(parent, parentScope, data) {
  parent
    .querySelectorAll('[data-mode="children"]')
    .forEach((el) => {
      let relation = el.dataset.scope;
      let collection = S.data({items: [], errors: []});

      S(async () => {
        let global = state();
        let display = (global.children === relation) ? '' : 'none';
        el.style.display = display;
        if (display != 'none' && global.id) {
          let {items, errors} = await searchChildren(parentScope, global.id, relation, {});
          collection({items, errors});
        }
      });

      bindEach(el, collection, (itemEl, item) => setHrefs(itemEl, item))
    });
}

function bindShowMode(parent) {
  parent
    .querySelectorAll("[data-mode='show']")
    .forEach((el) => {
      let scope = el.dataset.scope;
      let form = S.data({item: {}, errors: []});
      bindDisplay(el, async () => {
        let id = state().id;
        let {item, errors} = await readItem(scope, id);
        form({item, errors});
      });
      bindForm(el, form);
      bindLinks(el, form)
      bindChildrenMode(el, scope, form);
    });
}

function bindEditMode(parent) {
  parent
    .querySelectorAll("[data-mode='edit']")
    .forEach((el) => {
      let scope = el.dataset.scope;
      let form = S.data({item: {}, errors: []});
      bindDisplay(el, async () => {
        let id = state().id;
        let {item, errors} = await readItem(scope, id);
        form({item, errors});
      });
      bindForm(el, form);
      bindPickup(el, form);
      bindLinks(el, form);


      el
        .querySelectorAll('[data-action]')
        .forEach((control) => {
          control.addEventListener("click", async (e) => {
            e.preventDefault();
            let f = form();
            let id = state().id;
            let {item, errors} = await updateItem(scope, id, f.item);
            if (!errors.length) {
              form({item: item});
              visit(`#/${scope}/${id}`)
            }
          });
        });
    });
}

function bindDeleteMode(parent) {
  parent
    .querySelectorAll("[data-mode='delete']")
    .forEach((el) => {
      let scope = el.dataset.scope;
      let form = S.data({item: {}, errors: []});
      bindDisplay(el, async () => {
        let id = state().id;
        let {item, errors} = await readItem(scope, id);
        form({item, errors});
      });
      bindForm(el, form);
      bindLinks(el, form);

      el
        .querySelectorAll('[data-action]')
        .forEach((control) => {
          control.addEventListener("click", async (e) => {
            e.preventDefault();
            let id = state().id;
            let {item, errors} = await deleteItem(scope, id);
            if (!errors.length) {
              form({item: item});
              visit(`#/${scope}`)
            }
          });
        });
    });
}

function bindCreateAction(el, form, scope) {
  el
    .querySelectorAll('[data-action="create"]')
    .forEach((control) => {
      control.addEventListener("click", async (e) => {
        e.preventDefault();
        let f = form();
        let {errors} = await createItem(scope, f.item);
        if (!errors.length) {
          form({item: {}});
          visit(`#/${scope}`)
        }
      });
    });

}

function bindNewMode(parent) {
  parent
    .querySelectorAll("[data-mode='new']")
    .forEach((el) => {
      let scope = el.dataset.scope;
      let form = S.data({item: {}});
      bindDisplay(el);
      bindForm(el, form);
      bindPickup(el, form);
      bindCreateAction(el, form, scope);
    });
}

function bindNewChildMode(parent) {
  parent
    .querySelectorAll("[data-mode='newChild']")
    .forEach((el) => {
      let scope = el.dataset.scope;
      let childScope = el.dataset.childScope;
      let relation = el.dataset.relation;
      let inverseRelation = el.dataset.inverseRelation;
      let form = S.data({item: {}, errors: []});

      S(async () => {
        let global = state();
        let display = global.mode === 'newChild'
          && global.collection === scope
          && global.children === relation;
        el.style.display = display ? '' : 'none';
        if (display) {
          let {item ,errors} = await readItem(scope, global.id);
          let f = S.sample(form);
          f.item[inverseRelation] = item;
          form(f);
        }
      });

      bindForm(el, form);
      bindLinks(el, form)
      bindPickup(el, form);
      bindCreateAction(el, form, childScope);
    });
}

function bindEach(parent, collection, itemFn) {

  parent
    .querySelectorAll('[data-each]')
    .forEach((template) => {
      let child = template.content.firstElementChild.tagName;
      let parent = template.parentElement;
      let collectionName = template.getAttribute('data-each');

      S(() => {
        let col = collection();
        let children = col.items.map((item) => {
          let copy = template.content.cloneNode(true)

          copy
            .querySelectorAll('[data-name]')
            .forEach((el) => {
              let path = el.dataset.name;
              value = prop(item, path);
              el.textContent = value;
            });

          itemFn(copy, item);


          return copy;
        });

        parent
          .querySelectorAll(child)
          .forEach((child) => parent.removeChild(child));

        children.forEach((child) => parent.appendChild(child));
      });
    });
}

function bindListMode(parent) {
  parent
    .querySelectorAll("[data-mode='list']")
    .forEach((el) => {
      let scope = el.dataset.scope;
      let collection = S.data({items: [], errors: []});

      bindDisplay(el, async function() {
        let {items, errors} = await searchItems(scope, {});
        collection({items, errors});
      });


      bindLinks(el, state);
      bindFilter(el, scope, collection);
      bindEach(el, collection, (itemEl, item) => setHrefs(itemEl, item));
    });
}

function bindPickup(parent, form) {
  parent
    .querySelectorAll('[data-pickup]')
    .forEach((el) => {
      let scope = el.dataset.pickup;
      let formFieldName = el.dataset.pickupName;
      let query = S.data("");
      let collection = S.data({items: [], errors: []});

      S(async () => {
        let q = query()

        if (q.length) {
          let {items, errors} = await searchItems(scope, {query: q});
          collection({items, errors});
        } else {
          collection({items: [], errors: []})
        }

        el
          .querySelectorAll('[data-pickup-input]')
          .forEach((input) => input.value = q);
      });

      el
        .querySelectorAll('[data-pickup-input]')
        .forEach((input) => {
          input.onkeyup = debounce(async function() {
            query(input.value);
          }, 300);
        });

      el
        .querySelectorAll('[data-pickup-selection]')
        .forEach((el2) => {
          let fieldName = el2.dataset.pickupSelection;
          let path = `${formFieldName}.${fieldName}`;

          S(() => {
            let item = form().item;
            el2.textContent = prop(item, path);
          });
        });

      bindEach(el, collection, (itemEl, item) => {
        itemEl
          .firstElementChild
          .addEventListener('click', (event) => {
            query("");
            let f = form();
            f.item[formFieldName] = item;
            form(f);
          });
      });
    });
}

window.addEventListener('hashchange', route)

route();
token(readToken());

S.root(() => {
  bindClasses(document);
  bindNavMode(document);
  bindShowMode(document);
  bindEditMode(document);
  bindDeleteMode(document);
  bindNewMode(document);
  bindListMode(document);
  bindNewChildMode(document);
  bindPrivateMode(document);
  bindPublicMode(document);
});


