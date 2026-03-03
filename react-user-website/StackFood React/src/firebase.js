import { initializeApp, getApps, getApp } from 'firebase/app'
import {
    getMessaging,
    getToken,
    onMessage,
    isSupported,
} from 'firebase/messaging'
import { getAuth } from 'firebase/auth'

const firebaseConfig = {
    apiKey: 'AIzaSyB0Qgw61bc8PTsWP1qfPtI0zGk25OwhM_w',
    authDomain: 'soso-delivery-b7026.firebaseapp.com',
    projectId: 'soso-delivery-b7026',
    storageBucket: 'soso-delivery-b7026.appspot.com',
    messagingSenderId: '834616542221',
    appId: '1:834616542221:web:8561465b7b400e52cf8144',
    measurementId: 'G-SQ042QLE27',
    databaseURL: 'https://soso-delivery-b7026-default-rtdb.firebaseio.com',
}
const firebaseApp = !getApps().length ? initializeApp(firebaseConfig) : getApp()
const messaging = (async () => {
    try {
        const isSupportedBrowser = await isSupported()
        if (isSupportedBrowser) {
            return getMessaging(firebaseApp)
        }

        return null
    } catch (err) {
        return null
    }
})()

export const fetchToken = async (setFcmToken) => {
    return getToken(await messaging, {
        vapidKey:
            '',
    })
        .then((currentToken) => {
            if (currentToken) {
                setFcmToken(currentToken)
            } else {
                setFcmToken()
            }
        })
        .catch((err) => {
            console.error(err)
        })
}

export const onMessageListener = async () =>
    new Promise((resolve) =>
        (async () => {
            const messagingResolve = await messaging
            onMessage(messagingResolve, (payload) => {
                resolve(payload)
            })
        })()
    )
export const auth = getAuth(firebaseApp)
