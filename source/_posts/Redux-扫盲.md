---
title: Redux 扫盲
date: 2018-03-25 
tags: 前端
---

## 1. Redux 是什么，能做什么

对于 React 应用来说，为了实现页面上的各种交互我们必然要使用到 state 去管理页面状态，对于简单应用来说仅仅使用 React 的 state 尚且能够实现，但是随着应用复杂度变高以及页面交互逐渐增多，单单用静态的 React 去做数据交互会使整个项目变得冗杂臃肿。所以这里我们需要一个“东西”帮我们完美地处理这些数据，因此 Redux 应运而生。

[![](https://upload-images.jianshu.io/upload_images/3028410-ae20035c3f388004.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2018/03/25/Redux-%E6%89%AB%E7%9B%B2/logo.png) 

**Redux 是 facebook 提出的 flux 架构的一种优秀实现；而且不局限于为 react 提供数据状态处理。它是零依赖的，可以配合其他任何框架或者类库一起使用。**

对于复杂的单页面应用，状态（state）管理非常重要。state 可能包括：服务端的响应数据、本地对响应数据的缓存、本地创建的数据（比如，表单数据）以及一些 UI 的状态信息（比如，路由、选中的 tab、是否显示下拉列表、页码控制等等）。如果 state 变化不可预测，就会难于调试（state 不易重现，很难复现一些 bug）和不易于扩展（比如，优化更新渲染、服务端渲染、路由切换时获取数据等等）

**Redux 就是用来确保 state 变化的可预测性。Redux用一个单独的常量状态树（对象）保存一整个应用的状态，这个对象不能直接被改变。当一些数据变化了，一个新的对象就会被创建**（使用actions和reducers，后面会详细说明）。

<!--more-->

## 2. Flux 插播

前面提到 Redux 是 Facebook 提出的 Flux 架构的一种优秀实现，那么 Flux 又是什么呢？

简单说，Flux 是一种架构思想，专门解决软件的结构问题。类似于 MVC 架构，但是更加简单和清晰（可别以为是一回事哈）。

**Flux应用有三个主要部分：Dispatcher 调度 、存储 Store 和视图 View(React 组件)**，这些不应该和 MVC: Model-View-Controll(模型-视图-控制器)混淆，控制器在Flux应用中是存在的，但是他们是controller-view(控制器-视图)，视图通常在一个结构顶部，而这种结构是用来从存储stroe获得数据，然后将数据传递到自己的子结构们。

Flux 使用**单向数据流**（见下图）方式来避开 MVC. 当用户与 React 视图交互的时候，视图会通过中枢dispatcher 产生一个 action。然后大量的保存着应用数据和业务逻辑的视图接收到冒泡的 action，更新所有受影响的 view。这种方式很适合 React 这种声明式的编程方式，因为它的 store 更新，并不需要特别指定如何在 view 和 state 中过渡。

[![](https://upload-images.jianshu.io/upload_images/3028410-f87ba365b7e3e591.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2018/03/25/Redux-%E6%89%AB%E7%9B%B2/flux.png) 

如果想详细了解 Flux 可参见[这里](http://www.ruanyifeng.com/blog/2016/01/flux.html)

## 3. Redux VS Flux

**Redux是对Flux的演进和改变。**Redux从Flux中借鉴了几个非常重要的特性。

**Redux和Flux的相同点：**

Redux规定你必须将model update logic集中到应用特定的layer上(Flux中是”stores”，Redux中是”reducers”)。
Redux和Flux都不允许直接修改data，而是必须通过叫做”action”的plain object来描述对data的修改。

**Redux和Flux的不同点：**

Redux 没有 Flux 中 Dispatcher 的概念。Redux 使用纯函数来代替 Redux 中的 event emitter，而纯函数更容易管理，所以并不需要类似 Dispatcher 这样额外的实体来管理他们。看待的角度不同的话，这种实现方式跟 Flux 有差异也可能认为仅仅是实现细节不一致。而 Flux 经常被描述为 (state, action) => state。从这个概念来说的话，Redux 的确是 Flux 架构的一种，只是得益于纯函数而变得更加简单而已。

Redux 跟 Flux 另外一个重要的区别是，Redux假设你永远不会直接改变数据。在 state 中使用plain objects 和 arrays 都是允许的，但是在 reducers 中直接修改它们是不被允许的。正确的做法应该是返回一个新的对象给 state 替换相应的字段，这个新对象可以很容易实现，通过使用 babel 支持的 ES7 的 object spread syntax 等方法实现。

## 4. Redux 主要概念

### action

**Action 就是一个普通 JavaScript 对象，描述发生了什么。**

action 可以理解为应用向 store 传递的数据信息（一般为用户交互信息）。Action 本质上是 JavaScript 普通对象。我们约定，action 内必须使用一个字符串类型的 type 字段来表示将要执行的动作。多数情况下，type 会被定义成字符串常量。当应用规模越来越大时，建议使用单独的模块或文件来存放 action。除了 type 字段外，action 对象的结构完全由你自己决定。

为了便于测试和易于扩展，Redux 引入了 Action Creator，例如:

```
function addTodo(text) {

  return {

    type: ADD_TODO,

    text,

  }

}
```

要在应用里任何地方调用actions，是很简单的。使用dispatch方法，像这样：

```
dispatch(addTodo(text))
```

### Reducer

**Reducers 指定了应用状态的变化如何响应 actions 并发送到 store 的，记住 actions 只是描述了有事情发生了这一事实，并没有描述应用如何更新 state。**

在 Redux 中，reducer 就是获得这个应用的当前状态和事件然后返回一个新的状态的函数（纯粹的）。这里是一个非常简单的 reducer,通过获取当前状态和一个 action 作为参数，再返回下一个状态，通常我们会使用 switch 来区分不同的 action 类型应如何更新 state，例如：

```
function todoApp(state = initialState, action) {

  switch (action.type) {

    case SET_VISIBILITY_FILTER:

      return Object.assign({}, state, {

        visibilityFilter: action.filter

      })

    default:

      return state

  }

}
```

如果一个对象（状态）只改变一些值，Redux就创建一个新的对象，那些没有改变的值将会指向旧的对象而且新的值将会被创建。

**这里需注意两点：**

*   **不要修改 state** （使用 Object.assign() 新建了一个副本。不能这样使用 Object.assign(state, { visibilityFilter: action.filter })，因为它会改变第一个参数的值。）
*   **在 default 情况下返回旧的 state** （遇到未知的 action 时，一定要返回旧的 state）

对于更多复杂的项目，可以使用 Redux 提供的 combineReducers() 。它把在这个应用中所有的reducer 结合在一起成为单个索引 reducer。每一个 reducer 负责它自己那部分应用的状态，这个状态参数和其他 reducer 的不一样。combineReducers()实例使文件结构更容易维护。

### store

前面说到 action 用来描述“发生了什么”，使用 reducers 来根据 action 更新 state。

**Store 就是把它们联系到一起的对象。Store 有以下职责：**

*   维持应用的 state；
*   提供 getState() 方法获取 state；
*   提供 dispatch(action) 方法更新 state；
*   通过 subscribe(listener) 注册监听器;
*   通过 subscribe(listener) 返回的函数注销监听器。

创建好 store 后我们需要在页面中引入才能使用数据，在 Redux 中我们可以使用 createStore() 方法，在 react-redux 中可以直接使用 connect 方法引入 store。

```
import { createStore } from ‘redux’;

function authUser(form) {

  return {

    type: LOGIN_FORM_SUBMIT,

    payload: form

  }

} 

let store = createStore(rootReducer);

let authInfo = {username: ‘alex’, password: ‘123456’};

store.dispatch(authUser(authInfo));
```

## 5. Redux 工作原理

Redux 架构采用严格的**单向数据流**。这意味着应用中所有的数据都遵循相同的生命周期，这样可以让应用变得更加可预测且容易理解。

[![](https://upload-images.jianshu.io/upload_images/3028410-f58941249acbcd04.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2018/03/25/Redux-%E6%89%AB%E7%9B%B2/redux.png) 

以上图为例，Redux 应用中数据的生命周期为：

1.  UI 监听事件（例如 onclick）需要更新 state
2.  调用 Action creator dispatch 一个 action，表明需要做什么
3.  Redux store 调用传入的 reducer 函数，reducer 根据 action 的类型返回一个新的 state并保存到 Redux store 中
4.  store 中 state 的变化触发页面重新 render，页面上即可获得最新 state

## 6. Redux 三大原则

Redux 可以用这三个基本原则来描述：

### 单一数据源

**整个应用的 state 被储存在一棵 object tree 中，并且这个 object tree 只存在于唯一一个 store 中**

简言之就是整个应用的 state 是以树形结构存在的，整棵树存储在唯一的 store 中，当我们需要使用 store 中的某些数据时，只需要从根 state 中取即可。这样使得调试也变得非常容易。在开发中，你可以把应用的 state 保存在本地，从而加快开发速度。此外，受益于单一的 state tree ，以前难以实现的如“撤销/重做”这类功能也变得轻而易举。

### State 是只读的

**Redux 中唯一改变 state 的方法就是触发 action。**

这样确保了视图和网络请求都不能直接修改 state，相反它们只能表达想要修改的意图。因为所有的修改都被集中化处理，且严格按照一个接一个的顺序执行，因此不用担心多个地方同时修改 state 所造成的“脏数据”情况发生。

### 使用纯函数来执行修改

**为了描述 action 如何改变 state tree ，我们需要编写 reducers。**

Reducer 只是一些纯函数，它接收先前的 state 和 action，并返回新的 state。刚开始你可以只有一个 reducer，随着应用变大，你可以把它拆成多个小的 reducers，分别独立地操作 state tree 的不同部分，因为 reducer 只是函数，你可以控制它们被调用的顺序，传入附加数据，甚至编写可复用的 reducer 来处理一些通用任务，如分页器。

例如，

```
function todos(state = [], action) {

  switch (action.type) {

    case 'ADD_TODO':

      return [

        ...state,

        {

          text: action.text,

          completed: false

        }

      ]

    case 'COMPLETE_TODO':

      return state.map((todo, index) => {

        if (index === action.index) {

          return Object.assign({}, todo, {

            completed: true

          })

        }

        return todo

      })

    default:

      return state

  }

}
```

## 7. Connect with React

Redux 可以结合框架和类库一起使用，Redux 官方提供的 react-redux 将 react 和 redux 结合在了一起。这使得在 React 应用中可以更简便地使用 Redux。

***第一步：***

react-redux 提供了 Provider 标签，我们需要在 rendering 之前将 root component 包含在<provider>标签之内，Provider 有个属性 store 把我们创建的 store 传入，用法如下：</provider>

[![](https://upload-images.jianshu.io/upload_images/3028410-fc48a085a685fb37.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2018/03/25/Redux-%E6%89%AB%E7%9B%B2/react-redux1.png) 

上面这段代码，使得<provider>标签下面的Components都能访问到store instance。（内部是通过React的“context”特性来实现的）。</provider>

***第二步：***

我们需要使用 react-redux 提供的 connect() 函数，将那些我们想要跟 Redux 进行连接的components 包含起来。任意的 component 通过 connect() 调用包含之后，这个 component 的props 中都会包含一个 dispatch 函数和它需要的任意 state(global state 中的一部分经过变换而来)。

其中，dispatch function 的获取很简单，我们在 component 内部只需要直接使用this.props.dispatch 就能拿到一个用来 dispatch actions 的 function。而对于 component所需要的 state 数据，则需要一个额外的 selector function 作为 connect 的参数传入，这个selector function 的参数是 global Redux store’s state，它会把这个 global state 进行变换，处理成 component 所需要的数据返回。看下面的代码：

[![](https://upload-images.jianshu.io/upload_images/3028410-f092fba7e063d849.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2018/03/25/Redux-%E6%89%AB%E7%9B%B2/react-redux2.png) 

通过这种方式，我们就可以在页面上随意地使用 state 中的数据了。

## 写在最后

附上我在学习 redux 过程中做的一个小 demo，仅供参考。

[我是 demo](https://github.com/XLuoChen/react-redux-todolist)

