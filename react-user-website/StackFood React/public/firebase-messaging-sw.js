importScripts(
    'https://www.gstatic.com/firebasejs/9.13.0/firebase-app-compat.js'
)
importScripts(
    'https://www.gstatic.com/firebasejs/9.13.0/firebase-messaging-compat.js'
)
firebase?.initializeApp({
    apiKey: 'AIzaSyB0Qgw61bc8PTsWP1qfPtI0zGk25OwhM_w',
    authDomain: 'soso-delivery-b7026.firebaseapp.com',
    projectId: 'soso-delivery-b7026',
    storageBucket: 'soso-delivery-b7026.appspot.com',
    messagingSenderId: '834616542221',
    appId: '1:834616542221:web:8561465b7b400e52cf8144',
    measurementId: 'G-SQ042QLE27',
    databaseURL: 'https://soso-delivery-b7026-default-rtdb.firebaseio.com',
})

// Retrieve firebase messaging
const messaging = firebase?.messaging()

messaging.onBackgroundMessage(function (payload) {
    const notificationTitle = payload.notification.title
    const notificationOptions = {
        body: payload.notification.body,
    }

    self.registration.showNotification(notificationTitle, notificationOptions)
})
