use std::net::SocketAddr;
use tokio::net::TcpListener;
use warp::Filter;
use warp::hyper::StatusCode;

#[tokio::main]
async fn main() {
    println!("Starting up...");
    let url = "0.0.0.0:3014";
    let listener = TcpListener::bind(url)
        .await
        .unwrap();

    println!("Listing on default URL");

    tokio::spawn(async move {
        run_health_check().await;
    });

    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                let addr = stream.peer_addr().expect("connected streams should have a peer address");
                println!("Peer address: {}", addr);

                let ws_stream = tokio_tungstenite::accept_async(stream)
                    .await
                    .expect("Error during the websocket handshake occurred");

                println!("New WebSocket connection: {}", addr);

                drop(ws_stream);
            }
            Err(e) => panic!("{:#?}", e),
        }
    }
}

async fn run_health_check() {
    let routes = warp::get()
        .and(warp::path("health"))
        .map(move || Ok(warp::reply::with_status("", StatusCode::OK)))
        .with(warp::cors().allow_any_origin());

    let socket_address: SocketAddr = "0.0.0.0:3015".to_string().parse().unwrap();

    warp::serve(routes).run(socket_address).await;
}